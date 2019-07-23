# RION-DA-20-Adaption
Making the RION DA-20 vibration/noise sensor usable even if you don't have access to the software.

RION DA-20 Manual: https://www.viaxys.com/app/download/10048456/DA-20+Instruction+Manual+40750.pdf

Currently [7/23/2019], the file is verified to work in MATLAB, have not tried it in Octave. It allows you to plug in the memory storage card from a RION DA-20 and extract all of the data in a readily usable format. I've written a few functions for data visualization and exporting data in CSV format. It took me a while to wade through the documentation and to extract the data byte by byte, so I'm posting my program here so that no one else has to deal with it again. 
