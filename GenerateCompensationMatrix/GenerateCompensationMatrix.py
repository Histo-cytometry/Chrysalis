# @File(label = "Compensation file") file
# @Boolean(label = "Plot the spectra") doPlot
# @Boolean(label = "Save the plot as PNG") doSavePlot
# @Boolean(label = "Save as SDM (Leica,XML)") doSaveSDM
# @Boolean(label = "Save as CSV (one dye per column)") doSaveCSV

# This script automatically generates spectra plots and profiles from single-dye beads.
#
# Input : an image where each dye is recorded as a separate series. Each series
#         contains an image with N channels.
#
# Output : - a plot of the spectra (optionally saved as PNG)
#          - an XML file analogous to the SDM format from Leica
#          - a CSV file with each column corresponding to a dye
#
# Method : the script opens each series and for each calculates a threshold from the maximum intensity projection
#          using the 'triangle' algorithm. It then uses the threshold to calculate the mean intensity above the 
#          threshold. 

# 
# First version : 2017.09.14

from loci.plugins import BF
from loci.formats import ImageReader
from loci.plugins.in import ImporterOptions
from ij.plugin import ZProjector
from ij.process import AutoThresholder,ImageStatistics
from math import isnan
from ij import IJ

# Open all files in the series
options = ImporterOptions()
options.setOpenAllSeries(True)
options.setId(file.absolutePath)
options.setQuiet(True)
imps = BF.openImagePlus(options)

# Initialize XML and arrays where to store the values
xml = '<?xml version="1.0" encoding="utf-8"?><DyeData>'
profiles=[]
names=[]
for idye_,imp in enumerate(imps):
	idye = idye_+1

	# Assumes names are FILENAME+" - "+SERIESNAME
	names.append(imp.title.split(" - ")[1])

	xml+="<Dye%d>"%(idye)

	# ZProject
	zp = ZProjector(imp)
	zp.setMethod(zp.MAX_METHOD)
	zp.doProjection()
	imp_mi = zp.getProjection()
	imp_mip = imp_mi.getProcessor()

	# autothreshold using the Triangle method and get the thresholds
	imp_mip.setAutoThreshold(AutoThresholder.Method.Triangle,True)
	mint = imp_mip.getMinThreshold()
	maxt = imp_mip.getMaxThreshold()

	# we don't need the MIP anymore
	imp_mi.close()

	# For each channel, get the mean value above threshold and store it
	profile=[]
	for ich in range(imp.getNChannels()):
		p = imp.getStack().getProcessor(ich+1)

		p.setThreshold(mint,maxt,0)

		stats = ImageStatistics.getStatistics(p, ImageStatistics.MEAN | ImageStatistics.LIMIT, None)
		v = stats.mean

		# Deal with cases where no pixel is abote threshold
		if isnan(v):
			v = 0

		profile.append(v)

		xml+="<Ch%d>%f</Ch%d>"%(ich+1,v,ich+1)

	profiles.append(profile)
	
	xml+="</Dye%d>"%(idye)
	
	imp.close()
xml += "</DyeData>"

# Save the XML
if doSaveSDM:
	filename = file.absolutePath + "_compensations.sdm"
	with open(filename,'w') as f:
		f.write(xml)

# Save the CSV
if doSaveCSV:
	filename = file.absolutePath + "_compensations.csv"
	with open(filename,'w') as f:
		f.write(",".join(names)+"\n")
		for i in range(len(profiles[0])):
			row=[ str(p[i]) for p in profiles ]
			row=",".join(row)
			f.write(row+"\n")

# Generate a plot
if doPlot:
	from ij.gui import Plot
	from java.awt import Color
	p = Plot('Profiles','Channel #','Intensity')
	p.setSize(640,480)
	maxP = len(profiles)
	maxV = 0
	for iprofile,profile in enumerate(profiles):
		h = 0.66-(float(iprofile)/maxP)
		if h<0:
			h=h+1
		p.setColor(Color.getHSBColor( h,.8,1))
		p.addPoints(range(len(profile)),profile,p.LINE)
	
		maxV_=max(profile)
		if maxV < maxV_:
			maxV = maxV_
	p.setLimits(0,len(profile)-1,0,maxV*1.2)
	p.setLegend("\n".join(names),p.TOP_LEFT|p.LEGEND_TRANSPARENT)
	p.show()
	
	# Save the plot as PNG
	if doSavePlot:
		imp = p.getImagePlus()
		IJ.saveAs(imp,'PNG',file.absolutePath + "_compensationPlot.png")
