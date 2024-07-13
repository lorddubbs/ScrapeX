import logging, os

def setup_logs():
    log_dir = '/logs'
    log_file = f'{log_dir}/app.log'

    # Create the logs directory if it doesn't exist
    os.makedirs(log_dir, exist_ok=True)

    logging.basicConfig(
        level=logging.INFO,
        filename=log_file,
        filemode='a'
    )

    return logging.getLogger('ScrapeX')