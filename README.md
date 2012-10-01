# NSApplication+ESSApplicationCategory for OS X ReadMe

## What is NSApplication+ESSApplicationCategory?

A collection of possibly useful methods and functions.

Currently consisting of:
void ESSBeginAlertPanel(...)
void ESSBeginInformationalAlertPanel(...)
void ESSBeginCriticalAlertPanel(...)

These three functions are basically the same as their NSBegin*AlertPanel(...) counterparts, only that they use blocks for callbacks, not @selectors.

You might notice that the NSBegin*AlertPanel functions are declared in the header of the NSPanel class.
But since ESSBegin*AlertPanel builds on NSBegin*AlertPanel, it still uses the @selector callbacks to do its stuff which needs an instance of a class, and NSApplication is the perfect place for that, since any cocoa app has an instance of it.

## First, the License Agreement

1) You can use the code in your own products.  
2) You can modify the code as you wish, and use the modified code in your products.  
3) You can redistribute the original, unmodified code, but you have to include the full license text below.  
4) You can redistribute the modified code as you wish (without the full license text below).  
5) In all cases, you must include a credit mentioning Matthias Gansrigler as the original author of the source.  
6) I’m not liable for anything you do with the code, no matter what. So be sensible.  
7) You can’t use my name or other marks to promote your products based on the code.  
8) This framework uses the OAuthConsumer framework code which you can separately download from http://code.google.com/p/oauthconsumer/ which is made available under the MIT License.  
9) If you agree to all of that, go ahead and download the source. Otherwise, don’t.

# How To use NSApplication+ESSApplicationCategory

Just #import "NSApplication+ESSApplicationCategory.h" in your project and start using it :)

## Requirements
This code works on OS X Snow Leopard and later (tested only on OS X Mountain Lion)
Developed with Xcode 4.5

## Support
The framework and code is provided as-is, but if you need help or have suggestions, you can contact me anytime at [opensource@eternalstorms.at](mailto:opensource@eternalstorms.at) or [@eternalstorms on twitter](http://twitter.com/eternalstorms)

For other Open Source projects of mine, please visit http://www.eternalstorms.at/opensource

# I want to hear from you
If you use NSApplication+ESSApplicationCategory in one of your projects, please [let me know](mailto:opensource@eternalstorms.at)! I'd love to hear about your apps and mention them here on this project page :) !!