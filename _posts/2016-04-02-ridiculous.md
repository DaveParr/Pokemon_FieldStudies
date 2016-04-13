---
layout: post
title: "The Most Ridiculous Thing"
date: 2016-04-02
---

What follows is a transcription of the first known efforts of Pokemon Field Studdies by Professor dsparks:

Truly the most ridiculous thing I could think of.
Change to FALSE if you don't want packages installed.

```r
doInstall <- TRUE  
toInstall <- c("XML", "png", "devtools", "RCurl")
if(doInstall){install.packages(toInstall, repos = "http://cran.r-project.org")}
```

```
## Error in install.packages : Updating loaded packages
```

```r
lapply(toInstall, library, character.only = TRUE)
```

```
## [[1]]
##  [1] "knitr"     "RCurl"     "bitops"    "devtools"  "png"      
##  [6] "XML"       "stats"     "graphics"  "grDevices" "utils"    
## [11] "datasets"  "methods"   "base"     
## 
## [[2]]
##  [1] "knitr"     "RCurl"     "bitops"    "devtools"  "png"      
##  [6] "XML"       "stats"     "graphics"  "grDevices" "utils"    
## [11] "datasets"  "methods"   "base"     
## 
## [[3]]
##  [1] "knitr"     "RCurl"     "bitops"    "devtools"  "png"      
##  [6] "XML"       "stats"     "graphics"  "grDevices" "utils"    
## [11] "datasets"  "methods"   "base"     
## 
## [[4]]
##  [1] "knitr"     "RCurl"     "bitops"    "devtools"  "png"      
##  [6] "XML"       "stats"     "graphics"  "grDevices" "utils"    
## [11] "datasets"  "methods"   "base"
```

Some helper functions, lineFinder and makeTable


```r
source_gist("818983")
```

```
## Sourcing https://gist.githubusercontent.com/dsparks/818983/raw/315878a59c392a65b176a43c4903b3ede6b67864/LineFinder.R
```

```
## SHA-1 hash of file is ddeec1de75a917f6a1e0780efb8c99137789a412
```

```r
source_gist("818986")
```

```
## Sourcing https://gist.githubusercontent.com/dsparks/818986/raw/2af8efd88307cbbe7941d6be98834f166c56fc61/MakeTable.R
```

```
## SHA-1 hash of file is 9f922d395b04ac8aadea1e2c6cf91590be6e0d6d
```

In as few lines as possible, get statistics on each Pokemon


```r
importHTML <- readLines("http://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_base_stats_(Generation_I)")
theTable <- readHTMLTable(importHTML)
pokeTable <- theTable[[1]][, -2]
colnames(pokeTable)[1:2] <- c("N", "Name")
colnames(pokeTable) <- gsub("\n", "", colnames(pokeTable))
pokeTable[, -2] <- apply(pokeTable[, -2], 2, as.numeric)
pokeTable[, 2] <- as.character(pokeTable[, 2])
head(pokeTable)
```

```
##   N       Name  HP  Attack  Defense  Speed  Special  Total  Average
## 1 1  Bulbasaur  45      49       49     45       65    253     50.6
## 2 2    Ivysaur  60      62       63     60       80    325     65.0
## 3 3   Venusaur  80      82       83     80      100    425     85.0
## 4 4 Charmander  39      52       43     65       50    249     49.8
## 5 5 Charmeleon  58      64       58     80       65    325     65.0
## 6 6  Charizard  78      84       78    100       85    425     85.0
```

And find URLs for images of each


```r
pngURLs <- importHTML[lineFinder("http://cdn.bulbagarden.net/upload/",
                                 importHTML)]
pngURLs <- makeTable(makeTable(pngURLs, "src=\"")[, 2],
                     "\" width=\"40\"")[, 1]
```

Downloads & loads PNGs
# And assigns them to a list.
CAUTION: The following script will literally download 151 .PNG images of
Pokemon. Please be considerate, and don't run this more than you need to.


```r
pngList <- list()
for(ii in 1:nrow(pokeTable)){
  tempName <- pokeTable[ii, "Name"]
  tempPNG <- readPNG(getURLContent(pngURLs[ii]))  
  pngList[[tempName]] <- tempPNG  
  }
```

First time implemented in R
Look for it on CRAN


```r
iChooseYou <- function(pm){plot(1, 1)  
                           rasterImage(pngList[[pm]], 0.5, 0.5, 1.5, 1.5)                           
                           }
iChooseYou("Pikachu")  
```

![plot of chunk unnamed-chunk-6]({{ site.github.url  }}/figure/unnamed-chunk-6-1.png)

Principal component analysis


```r
PCA <- prcomp((pokeTable[, 3:7]))
biplot(PCA)  # To illustrate similarity of dimensions and individuals
```

![plot of chunk unnamed-chunk-7]({{ site.github.url  }}/figure/unnamed-chunk-7-1.png)

Plot:


```r
boxParameter <- 5  
plot(PCA$x, type = "n",
     xlab = "Overall stats >",
     ylab = "HP/Attack/Defense <> Speed/Special")
for(ii in 1:length(pngList)){
  Coords <- PCA$x[ii, 1:2]
  tempName <- pokeTable[ii, "Name"]
  rasterImage(pngList[[tempName]],
              Coords[1]-boxParameter, Coords[2]-boxParameter,
              Coords[1]+boxParameter, Coords[2]+boxParameter)
  }  
```

![plot of chunk unnamed-chunk-8]({{ site.github.url  }}/figure/unnamed-chunk-8-1.png)

Optional labels:


```r
text(PCA$x[, 1:2], label = pokeTable$Name, adj = c(1/2, 3))
```

```
## Error in text.default(PCA$x[, 1:2], label = pokeTable$Name, adj = c(1/2, : plot.new has not been called yet
```

