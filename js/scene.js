(function () {
  'use strict';

  var canvas = document.getElementById('hero-canvas');
  if (!canvas) return;

  var scene = new THREE.Scene();
  var camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
  var renderer = new THREE.WebGLRenderer({ canvas: canvas, alpha: true, antialias: true });
  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  renderer.setClearColor(0x0a0a0c, 1);

  camera.position.z = 8;

  // Soft gradient background via a large plane
  var bgGeometry = new THREE.PlaneGeometry(50, 50);
  var bgMaterial = new THREE.MeshBasicMaterial({
    color: 0x0a0a0c,
    transparent: true,
    opacity: 1
  });
  var bg = new THREE.Mesh(bgGeometry, bgMaterial);
  bg.position.z = -10;
  scene.add(bg);

  // Floating low-poly shapes
  var shapes = [];
  var colors = [0x00d4aa, 0x0088aa, 0x4444aa];
  var geometries = [
    new THREE.OctahedronGeometry(0.8, 0),
    new THREE.TetrahedronGeometry(0.9, 0),
    new THREE.IcosahedronGeometry(0.6, 0)
  ];

  for (var i = 0; i < 9; i++) {
    var geo = geometries[i % geometries.length];
    var mat = new THREE.MeshPhongMaterial({
      color: colors[i % colors.length],
      transparent: true,
      opacity: 0.2,
      flatShading: true
    });
    var mesh = new THREE.Mesh(geo, mat);
    mesh.position.set(
      (Math.random() - 0.5) * 12,
      (Math.random() - 0.5) * 10,
      (Math.random() - 0.5) * 6 - 2
    );
    mesh.rotation.set(Math.random() * 0.5, Math.random() * 0.5, 0);
    mesh.userData = { speed: 0.2 + Math.random() * 0.3, phase: Math.random() * Math.PI * 2 };
    scene.add(mesh);
    shapes.push(mesh);
  }

  // Ambient + point lights for depth
  scene.add(new THREE.AmbientLight(0x404060, 0.6));
  var pointLight = new THREE.PointLight(0x00d4aa, 0.4, 20);
  pointLight.position.set(4, 4, 6);
  scene.add(pointLight);
  var pointLight2 = new THREE.PointLight(0x0088aa, 0.3, 15);
  pointLight2.position.set(-4, -2, 4);
  scene.add(pointLight2);

  var clock = new THREE.Clock();

  function animate() {
    requestAnimationFrame(animate);
    var t = clock.getElapsedTime();
    shapes.forEach(function (mesh, i) {
      mesh.rotation.y += mesh.userData.speed * 0.01;
      mesh.rotation.x += mesh.userData.speed * 0.005;
      mesh.position.y += Math.sin(t + mesh.userData.phase) * 0.002;
    });
    renderer.render(scene, camera);
  }

  function onResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
  }

  window.addEventListener('resize', onResize);
  animate();
})();
