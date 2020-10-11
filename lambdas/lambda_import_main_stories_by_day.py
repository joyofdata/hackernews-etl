from hackernews_api import api
import datetime


def main(event, context):
    stories = api.get_main_stories_by_day(
        date=datetime.date(2020,8,20)
    )
    return len(stories)
