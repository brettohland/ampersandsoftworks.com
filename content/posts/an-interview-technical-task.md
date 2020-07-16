---
title: "An Interview Technical Task"
date: 2014-09-06T16:50:52+00:00
draft: false
tags: ["code-review"]
---

Recently I applied for a job as an iOS dev. As a part of the final interview process I was given a requirements document and told to build an app against it.

(Since I don't want this to come up if someone searches XXXX technical task, I'm not mentioning the company name)

>Create a clean XCode 5 iOS app project which presents a collection of 25 bundled images of your choosing, of various sizes, with at least the 2 following layout modes:
>
>- Mode 1: One image per row, stacked above one another.
>- Mode 2: Multiple images per row, starting a new row when there's not enough room for the next image on the current row.
>- Bonus layout modes:
>	- Randomize the width at which each image is displayed (range 10% to 90% of screen width) maintaining aspect ratio.
>	- Tap an image to select it, then tap a second image, which causes the two to trade places.
>	- Or surprise us :)
>
>Also write a couple paragraphs exploring the strengths and weaknesses of your solution's approach to presenting images from a (theoretical) 25,000 image collection. Focus on your presentation solution, not on the challenges of storing/bundling 25,000 images.
>
>Requirements:
>	- Provide a simple interface for mode selection.
>	- All image layout changes resulting from mode switching or device rotation *must* be animated. This is true for bonus layout modes as well.
>	- No third party libraries.


The end result was the following project on GitHub:

[IMG GRDVW](https://github.com/brettohland/IMG-GRDVW)

This is the paragraph I ended up writing about it:

### IMG GRDVW

![](/images/2014/Sep/IMGGRDVW-icon.png)

I decided, first off, to bring back the wild and heady days of "Web 2.0" and removed all of the vowels from the title of the app. I figured that would be a good first step.

I chose 25 of my own photographs as the data source, making sure that there were various sizes.

I implemented the following modes:

- **Mode 1:** One image per row, stacked above one another.
- **Mode 2:** Multiple images per row, starting a new row when there's not enough room for the next image on the current row.
- **Bonus Mode:** Tap an image to select it, then tap a second image, which causes the two to trade places.
- **Bonus Mode:** Cells will load an optimized image based on its current size to help performance and the app's memory footprint.
- **Added Bonus:** The app/icon isn't blue.

The app starts in Mode 2 and a pinch/zoom gesture will animate you to Mode 1. Tapping cells will activated the bonus mode.

The requirements were all delivered:

- Provide a simple interface for mode selection (gestures)
- All image mode and device orientation changes must be animated
- No 3rd party libraries

The task requirements made the decision to use a UICollectionView very easy to make. It's flexible, Apple loves it (read: well supported) and it gives you a lot of the animation niceties that the requirements needed. 

Because it's a UICollectionView, the grid can handle an image set of 25, 50, 100, 1000 or 25,000 images with relative ease. iOS will create, remove and cache cells as needed. The only real limitation is how long you can handle scrolling a grid. That said, the app was designed to handle just 25 as per required.

Scaling up the app to 25,000 images is an interesting thought experiment. Setting aside the questions surrounding getting those images into the app we end up with some issues that would need to be addressed:

- The app will only display between 1 - 3 columns of images. This would need to be changed in order to better support such a large data source. Adding more supported columns would help but ultimately there is a limit to how many images a resource constrained device can have in memory at one time.
- Taking Retina/Non-retina into account, each image has 6 versions that are currently included in the App's bundle. Each one had to be generated externally. Either network requests would need to be made to acquire smaller versions of the 25,000 image dataset or an image resizing step would need to be included in the app before a cell is populated.
 - Touch areas will get smaller as the images become more dense. Implementing a system similar to the iOS7 photos app where dragging a finger shows a larger preview would indeed help.
 - Swapping the positions of two cells that are thousands apart would be difficult, the chance of mis-tapping is too great on such a large list.
	 
The app falls short in several ways. If this were a shipping app I would add the following to the v2.0 to do list:

- Implement a waterfall UICollectionViewFlowLayout class that stacks the images more compactly based on size. The current app simply fits the images into a square box, resulting in too much whitespace around some images.
- Scrolling performance on the smallest image size isn't optimized as much as it could be. The externally generated images aren't as small as they could be.
- Resize all images on a background thread to not require multiple copies to be manually included in the app bundle.
- Add a REST API to acquire the images, including them into the app bundle is inefficient.
- Implement a drag to reorder system (similar to the system's springboard) to change order.
- Add iPad support.