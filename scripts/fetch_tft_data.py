from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from bs4 import BeautifulSoup
import time
import pandas as pd
import data_util as util

# hehe this code is super messy
# i will fix this later

driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()))
driver.get("https://app.mobalytics.gg/tft/team-comps")
soup = BeautifulSoup(driver.page_source, features="html.parser")

team_comp_urls = []
for url in soup.find_all('a', {"class": "m-tyi664"}):
    team_comp_urls.append(url["href"])

teams_csv = {
    "Team Name": [],
    "Description": [],
    "Roll Type": [],
    "Difficulty": [],
    "Rank": [],
    "Units": [],
    "Carousel Priority": []
}

synergies_csv = {
    "Team Name": []
}

augments_csv = {
    "Team Name": [],
    "Silver Augments": [],
    "Gold Augments": [],
    "Prismatic Augments": [],
    "Hero Augments": []
}

all_traits = util.add_all_traits(synergies_csv)

driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()))
for team_url in team_comp_urls:
    driver.get(util.MAIN_URL + team_url)
    time.sleep(2)   # give time for browser to load
    team_soup = BeautifulSoup(driver.page_source, features="html.parser")
    util.extract_team_info(team_soup, teams_csv, augments_csv, synergies_csv, all_traits)

util.save_tft_data(teams_csv, synergies_csv, augments_csv)