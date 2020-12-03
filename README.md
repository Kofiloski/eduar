# EduAR
EduAR my graduation project. iOS App that shows concept of delivering AR content natively.

The idea of the app was to be a game app, targeted at children, while also educating them.
I made a few concepts of delivering AR content through native iOS components. There are also Firebase models that were intended for over-the-air delivery of educational content, text and lectures about the AR object being displayed(Firebase is removed from this repo). 
The idea is for the educational institution to determine how to deliver the AR content, and what AR content to be delivered.

Each main screen game uses different aspects of the AR capibilty of the app.
1. The first game 'Find Max' dispalys random location around you and guides you through AR. Once the user reaches the location it displays the Dog in AR.
2. 'Build Setup' lets you build a computer setup on a flat surface infront of you. (Keyboard, mouse, monitor... etc). This has functionallity of rotating the object, moving it and enlarging it or shrinking it.
3. 'See Robot' is a basic native iOS AR viewer subclass of QLPreviewController, that previews object in AR.
4. 'Trees are Life' places the AR objects randomly around the user.


# Notice:
I do not own any of the artwork (AR objects) in the app.

# Requirements:
 iOS 12
 Swift 5
 Cocoapods 1.9.1
