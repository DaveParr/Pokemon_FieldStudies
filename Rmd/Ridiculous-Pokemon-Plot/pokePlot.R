# Truly the most ridiculous thing I could think of.

doInstall <- TRUE  # Change to FALSE if you don't want packages installed.
toInstall <- c("XML", "png", "devtools", "RCurl")
if(doInstall){install.packages(toInstall, repos = "http://cran.r-project.org")}
lapply(toInstall, library, character.only = TRUE)

# Some helper functions, lineFinder and makeTable
source_gist("818983")
source_gist("818986")

# In as few lines as possible, get statistics on each Pokemon
importHTML <- readLines("http://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_base_stats_(Generation_I)")
theTable <- readHTMLTable(importHTML)  # A useful function when it works
pokeTable <- theTable[[1]][, -2]
colnames(pokeTable)[1:2] <- c("N", "Name")
colnames(pokeTable) <- gsub("\n", "", colnames(pokeTable))
pokeTable[, -2] <- apply(pokeTable[, -2], 2, as.numeric)
pokeTable[, 2] <- as.character(pokeTable[, 2])
head(pokeTable)

# And find URLs for images of each
pngURLs <- importHTML[lineFinder("http://cdn.bulbagarden.net/upload/",
                                 importHTML)]
pngURLs <- makeTable(makeTable(pngURLs, "src=\"")[, 2],
                     "\" width=\"40\"")[, 1]

# CAUTION: The following script will literally download 151 .PNG images of
# Pokemon. Please be considerate, and don't run this more than you need to.

pngList <- list()
for(ii in 1:nrow(pokeTable)){
  tempName <- pokeTable[ii, "Name"]
  tempPNG <- readPNG(getURLContent(pngURLs[ii]))  # Downloads & loads PNGs
  pngList[[tempName]] <- tempPNG  # And assigns them to a list.
  }

iChooseYou <- function(pm){plot(1, 1)  # First time implemented in R
                           rasterImage(pngList[[pm]], 0.5, 0.5, 1.5, 1.5)                           
                           }
iChooseYou("Pikachu")  # Look for it on CRAN

# Principal component analysis
PCA <- prcomp((pokeTable[, 3:7]))
biplot(PCA)  # To illustrate similarity of dimensions and individuals

# Plot:
boxParameter <- 5  # To alter dimensions of raster image bounding box
plot(PCA$x, type = "n",
     xlab = "Overall stats >",
     ylab = "HP/Attack/Defense <> Speed/Special")
for(ii in 1:length(pngList)){
  Coords <- PCA$x[ii, 1:2]
  tempName <- pokeTable[ii, "Name"]
  rasterImage(pngList[[tempName]],
              Coords[1]-boxParameter, Coords[2]-boxParameter,
              Coords[1]+boxParameter, Coords[2]+boxParameter)
  }  # Optional labels:
text(PCA$x[, 1:2], label = pokeTable$Name, adj = c(1/2, 3))