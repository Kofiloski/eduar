# EduAR
EduAR is my graduation project. This project is an iOS App that shows couple of concepts of delivering AR content natively.

The idea of the app is to educate children through an iteractive game. This does not mean that it is limited to children.
I made a few concepts of delivering AR content through native iOS components. There are also Firebase models that were intended for over-the-air delivery of educational content, text and lectures about the AR object being displayed. However this feature is removed from this repo, only the models are present, should be enough get the point across.)=
The idea is for the educational institution(teacher) to determine how to deliver the AR content, and what that content should be.

Each game screen uses different aspects of the AR capabilities of the app. The games are the following:

1. The first game 'Find Max' displays a random location around you and guides you through AR. Once the user reaches the location it displays the dog in AR.
2. 'Build Setup' as second game that lets you build a computer setup on a flat surface in-front. (Keyboard, mouse, monitor... etc). This has functionality of rotating the object, moving(placing) it and enlarging or shrinking it. Tap on the flat surface to place the object.
3. 'See Robot' is a native iOS AR viewer subbclassed from QLPreviewController, that previews the object or presents it in AR.
4. The AR objects(plants) are placed randomly around the user when playing "Plants are Life".

# Notice:
I do not own any of the artwork (AR objects) in the app.

# Requirements:
- iOS 12

- Swift 5

- Cocoapods 1.9.1

# Installation guide
Make sure you have all requirements :)

- open Terminal
- git clone https://github.com/Kofiloski/eduar/
- cd eduar/EduAR
- pod install
- open EduAR.xcworkspace
