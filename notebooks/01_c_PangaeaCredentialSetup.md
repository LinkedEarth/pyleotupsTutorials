# Setting Up PANGAEA Credentials

## Overview

Some datasets on PANGAEA are protected and require authentication to access. This means you'll need to set up credentials (a special access key) before you can download certain data. This guide walks you through the process step by step, even if you're not familiar with programming.

PANGAEA credentials are personal to you and should be kept secure. We'll show you two easy ways to manage them: using built-in PyleoTUPS tools or a simple file-based approach.

## Why Do You Need Credentials?

- **Protected Datasets**: Some research data on PANGAEA is restricted to authorized users only
- **Your Account**: Credentials are linked to your PANGAEA account
- **Security**: This ensures data is used appropriately and citations are tracked

If you're only accessing public datasets, you might not need credentials. But for complete access to paleoclimate data, setting this up is recommended.

## Step 1: Obtaining Your PANGAEA API Token

First, you need to get your personal access token from PANGAEA. This is a unique code that identifies you.

### Instructions:

1. **Create or Log In to Your Account**
   - Go to: https://www.pangaea.de/user/login.php
   - If you don't have an account, create one (it's free for researchers)

2. **Access Your Profile**
   - After logging in, find your user profile or account settings

3. **Find Your API Token**
   - Look for your "API login token" or "access key" in your profile
   - This is usually a long string of letters and numbers
   - Copy this token - keep it private!

> **Important**: This token is unique to your account. Don't share it with others, and don't post it online.

## Step 2: Securely Storing Your Token

To keep your credentials safe and avoid typing them repeatedly, we'll store them securely. You have two options:

### Option A: Using PyleoTUPS Built-in Tools (Recommended)

PyleoTUPS provides simple functions to save and load your credentials automatically.

#### Save Your Credentials (One-Time Setup)

Run this code in a Python notebook or script:

```python
from pyleotups import save_pangaea_credentials

# Replace 'your_token_here' with your actual API token
save_pangaea_credentials("<your_token_here>")
```

This securely saves your token in a hidden location on your computer.

#### Load Credentials in Your Code

Whenever you need to use PANGAEA data, load your credentials like this:

```python
from pyleotups import load_pangaea_credentials

# This gets your saved token
pan_api = load_pangaea_credentials()
```

The variable `pan_api` now contains your token and can be used with PyleoTUPS.

### Option B: Manual Storage with .env File

If you prefer more control or are working in different environments, you can store credentials in a .env file.

#### Create a .env File

1. In your project folder, create a new file named exactly .env
2. Add this line to the file:
   ```
   PANGAEA_API="your_pangaea_token_here"
   ```
3. Replace `your_pangaea_token_here` with your actual token
4. **Important**: Enclose the token in double quotes

#### Security Notes:
- Add .env to your .gitignore file if using version control (Git)
- Never share or upload .env files
- Keep the file in your project root directory

## Step 3: Using Credentials in Your Research

Once stored, you can use your credentials with PyleoTUPS:

### For Manual .env Method:

```python
from dotenv import load_dotenv
import os

# Load the .env file
load_dotenv()

# Get your token
pan_api = os.getenv("PANGAEA_API")
```

### Initialize PyleoTUPS with Credentials:

```python
import pyleotups as pt

# Create a PANGAEA dataset object with your credentials
dataset = pt.PangaeaDataset(auth_token=pan_api)
```

Now you can search and download protected datasets!

## Troubleshooting

### "Credentials not found" error:
- Make sure you've run the save function or created the .env file correctly
- Check that your token is copied exactly (no extra spaces)

### "Invalid token" error:
- Verify your token from PANGAEA profile
- Tokens can expire - you may need to generate a new one

### Still can't access data:
- Some datasets may have additional restrictions
- Contact the dataset authors or PANGAEA support

## Next Steps

With credentials set up, you can now:
- Access protected PANGAEA datasets
- Use the full PyleoTUPS functionality for paleoclimate research
- Proceed to tutorials on searching and downloading data

For more information about PyleoTUPS capabilities, see the Next Guides on [NOAAObject](./02_a_NOAAObject.ipynb) and [PangaeaObject](./02_b_PANGAEAObject.ipynb).