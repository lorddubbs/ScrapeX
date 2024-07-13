import asyncio
from dotenv import load_dotenv
from utils.logger import setup_logs

async def main():
    logger = setup_logs()
    load_dotenv()

    while True:
        logger.info("Starting ScrapeX")
        await asyncio.sleep(10)

if __name__ == "__main__":
    asyncio.run(main())