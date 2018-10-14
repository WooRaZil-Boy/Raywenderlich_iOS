# Screencast Metadata

## Screencast Title

Coordinators

## Screencast Description

A coordinator design pattern, which makes heavy use of delegates and protocols, allows you to let your UIViewControllers do what they are best at - displaying views!  Things like navigation, networking, and in this example, interaction with HealthKit, are all delegated to the coordinator.  

## Language, Editor and Platform versions used in this screencast:

* **Language:** Swift 4.1
* **Platform:** iOS 11.3
* **Editor**: Xcode 9.3

# Script

For the script, please see the For Instructor/README.md file

#  Coordinators Screencast

**This screencast was based, in part, on a series of blog posts by Dave DeLong (@davedelong) - please be sure to check out what he has to say!**

## Sample Project Idea
Want an easy way to record your workouts and the water you consume during them, and store them in HealthKit?  This sample project lets you do just that, and uses a Coordinator Pattern to handle navigation, HealthKit interaction, and displays of alerts to the user.  

## Main Topics
* Each view controller defines a protocol, and contains a delegate object of that type.
* The coordinator adopts those protocols to help deal with navigation and other "heavy lifting" like interaction with HealthKit.
* The UIViewControllers are unaware of the rest of the app - they just display what they need to display, and pass on further activity to the coordintor.  


## Needs
* Graphics for the add water, enter workout calories, congratulations and error page.






