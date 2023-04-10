import re
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from bs4 import BeautifulSoup

MAIN_URL = "https://app.mobalytics.gg"
DATA_PATH = "./data/"

def add_all_traits(synergies_csv):
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()))
    trait_classes = add_trait_column(driver, "/tft/synergies/classes", synergies_csv, 'p', {"class": "m-pvjzf0 ehr3ysz0"})
    trait_origins = add_trait_column(driver, "/tft/synergies/origins", synergies_csv, 'p', {"class": "m-pvjzf0 ehr3ysz0"})

    return trait_classes + trait_origins

def add_trait_column(driver, url, csv, param, *argv):
    all_traits = []
    driver.get(MAIN_URL + url)
    soup = BeautifulSoup(driver.page_source, features="html.parser")

    for trait in soup.find_all(param, *argv):
        trait_name = trait.span.string
        csv[trait_name] = []
        all_traits.append(trait_name)
    
    return all_traits

def extract_team_info(s, teams_csv, augments_csv, synergies_csv, all_traits):
    team_name = s.find('div', {"class": "m-17xntb4"}).h1.string
    teams_csv["Team Name"].append(team_name)
    synergies_csv["Team Name"].append(team_name)
    augments_csv["Team Name"].append(team_name)
    teams_csv["Team Description"].append(s.find('div', {"class": "m-1vrrnd3"}).string.replace(' \n', ''))
    teams_csv["Roll Type"].append(s.find('div', {'class': "m-ttncf1"}).string.lower())
    teams_csv["Difficulty"].append(s.find('div', {'class': "m-17xntb4"}).find_all('div')[1].string.lower())
    teams_csv["Rank"].append(s.find('img', {'class': "m-68x97p"})["alt"].lower())

    units_html = s.find('div', {"class": "m-1bbfqqe"})
    units = []
    for unit in units_html.find_all('div', {"class": "m-1avyp1d"}):
        units.append(unit.find('div', {"class": "m-1lpv2x1"}).string.lower())
    teams_csv["Units"].append(units)

    carousel_priorities_html = s.find_all('img', {"class": "m-hl6zqa"})
    carousel_priorities = []
    for item in carousel_priorities_html:
        item_name = item["title"].replace('-', ' ')
        carousel_priorities.append(item_name)
    teams_csv["Carousel Priority"].append(carousel_priorities)

    augment_tiers = ["Best Silver Augments", "Best Gold Augments", "Best Prismatic Augments", "Best Hero Augments"]
    all_augments_html = s.find_all('div', {"class": "m-1cggxe8"})
    for i in range(4):
        augments_type = all_augments_html[i]
        augments_list = []
        for augment in augments_type.find_all('img', {"class": "m-1t5aiao"}):
            augments_list.append(re.sub('\d+', '', augment["title"].replace('-','')))   # some images end with a 1 for some reason?????
        if (augments_list == []):
            for augment in augments_type.find_all('img', {"class": "m-1wgeyf7"}):
                augments_list.append(re.sub('\d+', '', augment["title"].replace('-','')))   # some images end with a 1 for some reason?????
        augments_csv[augment_tiers[i]].append(augments_list)
    
    extract_trait_info(s, synergies_csv, all_traits)

def extract_trait_info(s, synergies_csv, all_traits):
    for trait in all_traits:
        synergies_csv[trait].append(0)
    for trait in s.find_all('div', {"class": "m-e2go8q"}):
        trait_name_html = trait.find('img', {"class": "m-1m0k2eo"})
        num_of_trait_html = trait.find('div', {"class": "m-166kdep"})
        if (trait_name_html == None or num_of_trait_html == None):
            trait_name_html = trait.find('img', {"class": "m-1mhyhni"})
            num_of_trait_html = trait.find('div', {"class": "m-tqp1w1"})
        trait_name = trait_name_html["alt"]
        num_of_trait = num_of_trait_html.string
        synergies_csv[trait_name][-1] = num_of_trait