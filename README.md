# Welcome to the Chrysalis Software Page


Chrysalis was developed by Dmitri I. Kotov and Thomas Pengo at the University of Minnesota. Chrysalis processes 3D images, like those acquired on confocal or epi-fluorescence microscopes, as well as two-photon movies (3D images + time) to prepare the images for further analysis in Imaris or ImageJ. 

Additionally, we have created the GenerateCompensationMatrix script. This script is run in Fiji and used with single color control images to generate a compensation matrix. This compensation matrix can then be used by Chrysalis to spectrally unmix images.

We have also created a group of Imaris Xtensions. These Xtensions aid in quantitative, multispectral image analysis in Imaris for 3D images and movies. Additionally, many of these Xtensions are intended for batch processing images. This batch functionality allows for the batching of histo-cytometry analysis, thereby greatly speeding up the histo-cytometry workflow.

The publication describing automation of histo-cytometry analysis with Chrysalis is here: http://www.jimmunol.org/content/202/1/300

Videos demonstrating how to use this code is available here: https://www.youtube.com/channel/UCvHIV4KcB83j_oB5rbHA65w

## Chrysalis Features


* *Spectral Unmixing*: This feature applies linear unmixing to the image based on a user defined "compensation matrix".

* *New Channel*: This feature generates a new channel that based on properties of existing channels. For example, this feature can be used to create a new channel that only contains voxels for dendritic cells by including channels for CD11c and MHCII while excluding channels for B220, F4/80, and CD3 and using CD11c as the signal intensity for this new channel.

* *Save movie as AVI file*: This feature is great for quickly looking over movies to determine which movies have healthy tissue and are worth analyzing further.

* *Merge all images in each file*: 3D images can use this feature to combine multiple images from a single tissue into one large image, thereby allowing for simultaneous analysis.


## Imaris Xtensions


The XTChrysalis, XTChrysalisImaris9, XTChrysalis2phtn, XT2phtnStatsExport, XTMovieSurfacesAndStats, XTCreateSurfaces, XTStatisticsExport, XTDistanceTransformOutsideObjectForBatchFirst2surfaces, XTDistanceTransformOutsideObjectForBatchLastNsurfaces, and XTBatchKissAndRun Xtensions are run through the XTBatchProcess Xtension thereby allowing for batched image analysis.

#### XTChyrsalis/XTChrysalisImaris9

This Xtension batches 3D image analysis for a group of images in Imaris. The XTChrysalisImaris9 version has slight modifications so that the Xtension is compatible with Imaris 9. The following steps are applied to each image:

1. Create new surfaces that subset DC surfaces based on Sortomato regions
2. Create new surfaces that identify activated DCs based on Sortomato regions
3. Calculate distances from each new surface to neighboring cells
4. Export TCR and DC surface statistics


#### XTChyrsalis2phtn

This Xtension batches two-photon movie analysis for a group of movies in Imaris. The following steps are applied to each movie:

1. Calculate distances from DCs to to neighboring cells
2. Quantify interactions between TCR Tg cells and DCs
3. Export TCR and DC surface statistics


#### Sortomato V2.0

This Xtension allows Imaris images to be analyzed in a similar manner to how FlowJo can be used to analyze flow cytometry data. Every statistic available for a surface can be plotted on a 2D plot against any other statistic, for example mean signal intensity of channel 1 can be plotted against mean signal intensity of channel 2. Regions can be identified on the 2D plot, similar to gating in FlowJo, and these regions can be used to subset existing surfaces into new surfaces.


#### XTMovieSurfacesAndStats

This Xtension also batches two-photon movie analysis for a group of movies in Imaris. The following steps are applied to each movie:
1. Create new surfaces that subset existing surfaces based on Sortomato regions
2. Calculate distances from each new surface to neighboring cells
3. Export TCR and DC surface statistics

#### XTCreateSurfaces

This Xtension batches the generation of new surfaces based on regions of existing surfaces that were identified with Sortomato.


#### XTStatisticsExport

This Xtension batches the exportation of statistics for TCR Tg cells and DC as a CSV file that can be directly imported in Flowjo for further quantitative analysis.


#### XTDistanceTransformOutsideObjectForBatchFirst2surfaces

This Xtension batches distance transformation for the initial two surfaces in the object list of multiple Imaris image files. Distance transformation calculates the distance from a surface to other cells.


#### XTDistanceTransformOutsideObjectForBatchLastNsurfaces

This Xtension batches distance transformation for the last N surfaces in the object list of multiple Imaris image files. Distance transformation calculates the distance from a surface to other cells. The N is set to 2, but can be quickly changed in Matlab by the end user.


## Acknowledgments

The XTChrysalis Xtension utilizes data generated by a customized version of the Sortomato Xtension (Sortomato V2.0). The original Sortomato Xtension was written by Peter Beemiller. Portions of the batchatable Imaris Xtensions were written by Matthew J. Gastinger.
