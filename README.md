StrEatFoodie
============
### The best and only [SoMaStrEatFood Park](http://somastreatfoodpark.com/) menubar app.


StrEatFoodie listens to SoMa StrEatFood's [Twitter](https://twitter.com/somastreatfood), finds the tweets that announce which trucks will
be at the park for lunch and dinner, and displays those trucks in a menubar popup.

StrEatFoodie uses these open source projects:

- [TweetPoller](https://github.com/jimmyoneill/TweetPoller)
- [Popup](https://github.com/shpakovski/Popup)
- [NSString+Levenshtein](https://github.com/aufflick/aufflick-cocoa-additions/tree/master/Cocoa%20Additions/NSString+Levenshtein)

## Setup 

- Clone [TweetPoller](https://github.com/jimmyoneill/TweetPoller) and follow the setup instructions for the TweetPoller project
- Clone StrEatFoodie in the same directory as TweetPoller

Open up StrEatFoodie.xcworkspace. If StrEatFoodie and TweetPoller are in the same directory, XCode will find the TweetPoller 
subproject, and building StrEatFoodie will automatically build libTweetPoller.