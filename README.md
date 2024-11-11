# README

## Introduction

- ios app based on flutter

- Backend repo: `https://github.com/Jiaqi9972/FindYourPet-Backend`
  
  - if not available. please contact: `qu9972@gmail.com`

- backend deployed on oracle cloud, now it can be visited by `http://165.1.64.212`
  
  - health check: GET `http://165.1.64.212/api/v1/health`

## Run the project

```shell
open -a Simulator
flutter run
```

## Coding part

- What I have done:
  
  - login user (auth by firebase)
  
  - add username and avatar (now string) when profile is not completed
  
  - add lost/found pet
  
  - add pet image (now string)
  
  - add pet details (name, description, date and time, contact, lost place)
    
    - lost place based on google map auto complete address
  
  - show lost/found pets on map
  
  - show lost/found pets in pagination list

- what I will add in the future
  
  - register and login on the app (now can only register on firebase console)
  
  - implement google login (now only email and password)
  
  - replace string (user avatar and pets) with real images
  
  - design new ui for homepage (Refer to TooGoodToGo's UI, seperate map and list)
  
  - improve the lost pet form
  
  - edit initial location for map (now it is SF, I'm not sure if simulator can get my real location)
  
  - allow users to send messages to each other (if possible, maybe needs update on backend)

## For professor and TA

- Please login if you want to test the add function.
  
  Email: qu9972@gmail.com Password: 123456

- Add a San Francisco address if you don't want to move the map.
