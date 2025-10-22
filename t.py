import asyncio
from telethon import TelegramClient
import os

# Your Telegram API credentials
api_id = 1234567  # Replace with your API ID
api_hash = 'your_api_hash_here'  # Replace with your API Hash
phone = 'your_phone_number'  # Replace with your phone number

async def main():
    client = TelegramClient('session_name', api_id, api_hash)
    await client.start(phone)
    
    # Replace with actual channel/message that contains 11M.txt
    message = await client.get_messages('channel_username', ids=123456)
    
    if message and message.file:
        print("Downloading 11M.txt...")
        await client.download_media(message, '11M.txt')
        print("Download completed!")
    else:
        print("File not found!")
    
    await client.disconnect()

if __name__ == '__main__':
    asyncio.run(main())
