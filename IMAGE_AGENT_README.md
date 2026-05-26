# SmartCart Image Generation Agent

An automated image generation agent that creates images from text prompts using Google's Gemini API and automatically commits them to GitHub using Octokit.

## Features

- 🎨 Generate images from text prompts using Google Gemini API
- 💾 Save generated images locally to organized folders
- 🔄 Automatically commit and push images to GitHub
- 🔐 Secure environment variable handling
- 📝 Detailed logging and error handling
- 🧪 Configuration validation

## Prerequisites

- Node.js 18+ 
- npm or yarn
- Google Gemini API key
- GitHub personal access token
- A GitHub repository to push images to

## Setup Instructions

### 1. Install Dependencies

```bash
npm install
```

### 2. Get API Keys

#### Google Gemini API Key
1. Go to [Google AI Studio](https://aistudio.google.com/)
2. Click "Get API key"
3. Create a new API key in Google Cloud Console
4. Copy the API key

#### GitHub Personal Access Token
1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Select scopes:
   - `repo` (Full control of private repositories)
   - `workflow` (Update GitHub Action workflows)
4. Copy the token immediately (you won't see it again)

### 3. Configure Environment Variables

Create a `.env` file in the root directory (copy from `.env.example`):

```bash
cp .env.example .env
```

Edit `.env` with your values:

```env
GEMINI_API_KEY=your_actual_gemini_key_here
GITHUB_TOKEN=your_actual_github_token_here
GITHUB_OWNER=your_github_username
GITHUB_REPO=your_repository_name
IMAGE_OUTPUT_DIR=./generated_images
COMMIT_MESSAGE_PREFIX=feat: Generated images from prompts
BRANCH_NAME=main
```

### 4. Verify Configuration

Test that your configuration is valid:

```bash
npm run test
```

You should see:
```
✓ All configurations valid
```

## Usage

### Run Image Generation

```bash
npm start
```

This will:
1. Generate images from predefined prompts
2. Save them locally to `./generated_images`
3. Commit them to your GitHub repository
4. Push the changes to the default branch

### Customize Prompts

Edit `imageAgent.js` and modify the `prompts` array in the `main()` function:

```javascript
const prompts = [
  'Your custom prompt 1',
  'Your custom prompt 2',
  'Your custom prompt 3',
];
```

## API Reference

### ImageGenerationAgent Class

#### Constructor
```javascript
const agent = new ImageGenerationAgent();
```

#### Methods

##### `generateImages(prompts)`
Generate images from an array of text prompts and commit them to GitHub.

**Parameters:**
- `prompts` (Array|String): Text prompt(s) to generate images from

**Returns:** Promise<Array> - Array of generated file objects

**Example:**
```javascript
const agent = new ImageGenerationAgent();
const results = await agent.generateImages([
  'A sunny beach',
  'A mountain landscape'
]);
```

##### `generateImageFromPrompt(prompt)`
Generate a single image from a text prompt.

**Parameters:**
- `prompt` (String): Text prompt for image generation

**Returns:** Promise<Object> - Image generation response

##### `commitAndPushToGitHub(files, commitMessage)`
Commit and push files to GitHub.

**Parameters:**
- `files` (Array): Array of file objects with `filepath` property
- `commitMessage` (String): Commit message

**Returns:** Promise<Object> - Commit result with SHA and URL

## Output Structure

Generated images are saved with the following naming convention:

```
generated_images/
├── 1234567890-prompt-name.png
├── 1234567891-another-prompt.png
└── 1234567892-third-prompt.png
```

Each filename contains:
- **Timestamp**: Unix timestamp (ensures uniqueness)
- **Sanitized prompt**: First 50 characters of the prompt, lowercase, alphanumeric only

## GitHub Integration

The agent uses Octokit to:
1. Create blobs for each image file
2. Create a new tree with all files
3. Create a commit referencing the new tree
4. Update the repository reference to point to the new commit

This ensures images are properly integrated into your repository history.

## Environment Variables Reference

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `GEMINI_API_KEY` | Yes | - | Google Gemini API key |
| `GITHUB_TOKEN` | Yes | - | GitHub personal access token |
| `GITHUB_OWNER` | Yes | - | GitHub username or organization |
| `GITHUB_REPO` | Yes | - | Repository name |
| `IMAGE_OUTPUT_DIR` | No | `./generated_images` | Local output directory |
| `COMMIT_MESSAGE_PREFIX` | No | `feat: Generated images from prompts` | Commit message prefix |
| `BRANCH_NAME` | No | `main` | Target branch for commits |
| `IMAGE_WIDTH` | No | `1024` | Image width (if supported) |
| `IMAGE_HEIGHT` | No | `768` | Image height (if supported) |

## Error Handling

The agent includes comprehensive error handling:

- **Missing environment variables**: Validates all required vars at startup
- **API failures**: Logs errors and continues with remaining prompts
- **Network issues**: Handles fetch/network errors gracefully
- **File system errors**: Creates directories automatically

## Logging Output

The agent provides detailed console output:

```
🚀 SmartCart Image Generation Agent Started
📁 Output directory: ./generated_images
📝 Processing 3 prompts...

🎨 Generating image from prompt: "A sunny beach"
✓ Image generated successfully
📥 Downloading image to: ./generated_images/1234567890-a-sunny-beach.png
✓ Image saved successfully

📤 Committing and pushing to GitHub...
✓ Successfully pushed to owner/repo/main
✓ Commit SHA: abc123def456

✅ Image generation complete!
📊 Generated 3 images
```

## Security Best Practices

⚠️ **Never commit `.env` to version control**

The `.env` file is already in `.gitignore`. Always:
- Use strong, unique API keys
- Rotate tokens periodically
- Use GitHub's token expiration settings
- Monitor API usage in Google Cloud Console and GitHub

## Troubleshooting

### "Missing environment variables" Error
- Ensure `.env` file exists
- Verify all required variables are set
- Run `npm run test` to validate

### "Failed to authenticate" Error
- Check GitHub token is valid and not expired
- Verify token has correct scopes
- Ensure `GITHUB_OWNER` and `GITHUB_REPO` are correct

### "Image generation failed" Error
- Verify Gemini API key is valid
- Check API quotas in Google Cloud Console
- Ensure API is enabled for your project

### "Failed to push to GitHub" Error
- Verify repository exists and is accessible
- Check token has `repo` scope
- Ensure branch name is correct

## Advanced Usage

### Process Multiple Batches

```javascript
const agent = new ImageGenerationAgent();

const batch1 = await agent.generateImages(['prompt1', 'prompt2']);
const batch2 = await agent.generateImages(['prompt3', 'prompt4']);
```

### Custom Commit Messages

```javascript
const files = [...]; // your files
const message = `feat: Added ${files.length} new product images\n\nGenerated on ${new Date().toISOString()}`;
await agent.commitAndPushToGitHub(files, message);
```

## Dependencies

- `@google/generative-ai`: Google Gemini API client
- `@octokit/rest`: GitHub API client
- `dotenv`: Environment variable management
- `axios`: HTTP client (for image downloads)
- `node-fetch`: Fetch API for Node.js

## License

MIT

## Support

For issues or questions:
1. Check the Troubleshooting section
2. Verify all prerequisites are met
3. Review console output for error messages
4. Check API service status pages
