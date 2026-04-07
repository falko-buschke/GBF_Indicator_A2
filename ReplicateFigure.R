# Load required packages
#install.packages(c("waffle", RColorBrewer", "quantreg", "rworldmap"))
library(RColorBrewer)	# Colour palettes
library(waffle)				# Figure 1
library(quantreg) 		# Quantile regression
library(rworldmap) 		# Producing maps

# Read the data from the cleaned database of 7th National Reports
GBF <- read.csv("Indicator A2.csv", na.strings = "NULL")

#########################################
#																				#
#									Figure 1 							#
#																				#
#########################################

# Summarise reporting status
parties <- 196 			# Total number of parties to CBD
submitted <- dim(GBF)[1]  #  Number of Parties that submitted 7th National Reports
Ind.A2 <- submitted - length(which(GBF$A2 == "No data available")) # Parties that eported on A.2
usable <- Ind.A2 - length(which(GBF$A2 == "Unclear"))  # Parties that Reprorted on A.2 in a meaningful way

# Group data for reporting status
group <- c("Did not submit 7th National Report\n(34.7 %)","Did not report Indicator A.2\n(27.0 %)",
	"Indicator A.2 incomplete\n(9.2 %)", "Complete Indicator A.2\n(29.1 %)")
value <- c(parties-submitted,submitted-Ind.A2, Ind.A2-usable,usable)
data <- data.frame(group,value)

# Set colour scheme
ramp <- brewer.pal(8,"Dark2")
ramp <- ramp[c(8,6,4,1)]

# Produce waffle plot
png(filename="Figure1.png",width=19,height=7,units="cm",res=300)
par(mai=c(0.1,0.1,0.6,0.1))
waffle(data, colors = ramp, legend_pos = "top", rows=7)
dev.off()

#########################################
#																				#
#									Figure 2 							#
#																				#
#########################################
# Set plot specification
png(filename="Figure2.png",width=28,height=12,units="cm",res=300)
par(mfrow=c(1,2))
par(mai=c(0.7,1.8,0.3,0.1))

# Panel A
# Remove the values for countries that did not report on Indicator A.2
data.type <- table(GBF$Data.Type)
data.type <- data.type[which(names(data.type)!="None")]
data.type <- data.type[order(data.type)]

# Make the Plot
barplot(data.type, horiz=TRUE, las=1, xlab="Number of Parties", xlim=c(0,30),
  main="", cex.axis=1.1, cex.lab= 1.3,mgp=c(2.6,0.6,0), col=rgb(0.2,0.4,0.5,1))
abline(v=0)
# Label the Panel
mtext("a. Data sources",cex=1.5, side = 3, adj = -0.8, line = 0.25,font=2)

# Remove the values for countries that did not report on Indicator A.2, but this time correct for countries
# that report ont he indicator, without including a disaggregation 
disaggr <- table(GBF$Disaggregation)
disaggr[which(names(disaggr)=="None")] <- disaggr[which(names(disaggr)=="None")] - length(which(GBF$A2 == "No data available"))
disaggr <- disaggr[order(disaggr)]

# Make the Plot
barplot(disaggr, horiz=TRUE, las=1, xlab="Number of Parties",  xlim=c(0,30),
  main="", cex.axis=1.1, cex.lab= 1.3,mgp=c(2.6,0.6,0), col=rgb(0.2,0.4,0.5,1))
abline(v=0)
mtext("b. Disaggregation",cex=1.5, side = 3, adj = -0.8, line = 0.25,font=2)
dev.off()

#########################################
#																				#
#									Figure 3 							#
#																				#
#########################################

# Read SBRN dataset
WRI <- read.csv("WRI_data.csv", na.strings = "NULL")

# Aggregate areas for the same countries (total, natural, and their proportion)
total <- xtabs(WRI$total_area_m2 ~ WRI$ISO3)
natural <- xtabs(WRI$class_1_area_m2 ~ WRI$ISO3)
natural[names(natural)=="GRL"] <- total[names(natural)=="GRL"]
prop <- natural /total

# For the country-reported data, reclassify the data that were not reported or had invalid values
GBF$A2[which(GBF$A2 == "No data available")] <- NA
GBF$A2[which(GBF$A2 == "Unclear")] <- NaN
GBF$A2 <- as.numeric(GBF$A2)

# Create an identitiy vector for countries in the SBTN data that also reported to CBD
id <- match(GBF$ISO3,names(prop))
index <- which(!is.na(prop[id]*GBF$A2))

# Define the dependen and independent variable
Depend <- prop[id][index]
Indep <- as.numeric(GBF$A2[index])

# Manually calculate the R2 value for the Unity line
SS.res <- sum((Depend - Indep)^2)   # Sum of squared residuals
y.mean <- mean(Depend)              # Mean of observed values
SS.tot <- sum((Depend - y.mean)^2)  # Sum of squared differences from mean
(R2 <- 1 -(SS.res/SS.tot))

# Unity line regression, start with linear OLS model
mod <- lm(Depend~Indep)
summary(mod)

# Calcualte the t-statistic for null hypotheis that slope = 1
t.stat <- (mod$coefficients[2] - 1)/summary(mod)$coefficients[4]
# Calcualte P-value
(p_value <- 2 * pt(abs(t.stat), df = mod$df.residual, lower.tail = FALSE))

# Estimate residuals from Unity line
Resid.calc <- Depend - Indep

# Set plot specification
png(filename="Figure3.png",width=24,height=12,units="cm",res=300)
par(mfrow=c(1,2))
par(mai=c(0.75,0.75,0.4,0.2))

# Make Plot for panel A
plot(GBF$A2,as.numeric(prop)[id], pch=16, col=rgb(0.2,0.4,0.5,0.6),las=1,cex=1.5, xlim=c(0,1), ylim=c(0,1),
xlab= "A.2 reported by Parties", ylab="A.2 estimated from SBTN dataset", cex.axis=1.1, cex.lab= 1.3,mgp=c(2.6,0.6,0))

# Add regression line andunity line (1:1)
abline(lm(prop[id]~GBF$A2), col="red", lty=2)
abline(a=0,b=1,col="blue")

# Add R-squared value to plot
text(0.15,0.9, bquote(R^2 == .(round(R2,3))),cex=1.2)
# Add legend
legend("bottomright", lty=c(1,2),col=c("blue", "red"), c("1:1 line", "Linear regression"))
# Label panel
mtext("a",cex=1.6, side = 3, adj = -0.1, line = 0.35,font=2)

##########################################

# Match area values in the vector of total area in SBTN data to Parties that reported A.2
id2 <- match(names(Resid.calc),names(total))

# Make Plot for panel B
plot(as.numeric(total)[id2]/1e9,as.numeric(Resid.calc),  pch=16, col=rgb(0.2,0.4,0.5,0.6),las=1,cex=1.5,
xlab= expression(paste("Country surface area (1000 x km"^"2",")")), ylab="Model residuals", cex.axis=1.1,  cex.lab= 1.3,mgp=c(2.6,0.6,0))
# Add horizontal axis
abline(h=0)

# Quantile regression
x.val <- as.numeric(total)[id2]/1e9
y.val <- as.numeric(Resid.calc)

quant_reg_01 <- rq(y.val ~ x.val, tau = 0.01)
quant_reg_05 <- rq(y.val ~ x.val, tau = 0.05)
quant_reg_95 <- rq(y.val ~ x.val, tau = 0.95)
quant_reg_99 <- rq(y.val ~ x.val, tau = 0.99)
# Add outer estimate
abline(a=quant_reg_01$coefficients[1], b=quant_reg_01$coefficients[2], lty=3, col="darkgrey")
abline(a=quant_reg_05$coefficients[1], b=quant_reg_05$coefficients[2], lty=2, col="darkgrey")
abline(a=quant_reg_95$coefficients[1], b=quant_reg_95$coefficients[2], lty=2, col="darkgrey")
abline(a=quant_reg_99$coefficients[1], b=quant_reg_99$coefficients[2], lty=3, col="darkgrey")

# Add legend
legend("bottomright", lty=c(2,3),col="darkgrey", c("0.1 & 0.99 Quantiles", "0.05 & 0.95 Quantiles"))
# Label panel
mtext("b",cex=1.6, side = 3, adj = -0.1, line = 0.35,font=2)
dev.off()

# Indicator A.2 for the whole planet
(Global.A.2 <- sum(as.numeric(natural))/sum(as.numeric(total))*100)

#########################################
#																				#
#									Figure 4 							#
#																				#
#########################################
# Define colour ramp
ramp <- colorRampPalette(brewer.pal(9,"YlGn"),interpolate="linear")(10)
brk <- seq(0,1,l=11)

# Set plot specifications
png(filename="Figure4.png",width=28,height=28,units="cm",res=300)
par(mfrow=c(2,1))
par(mai=c(0.2,0.1,0.2,0.1))

# Panel A
# Create dataframe
d <- data.frame(
  country=GBF$ISO3,
  index=as.numeric(GBF$A2),
  missing = rep(0,length(GBF$ISO3)))#(is.na(GBF$A2) | (GBF$A2 == "NaN")))

d$index[which(d$index=="NaN")]<- NA

# Spatial join
n <- joinCountryData2Map(d, joinCode="ISO3", nameJoinColumn="country")
n <- n[row.names(n) != 'Antarctica', ]
n$missing[which(is.na(n$missing))]<- 1

#Create Map
mapCountryData(n, nameColumnToPlot="index",mapTitle="", colourPalette = ramp, 
               borderCol="white", lwd=0.85, catMethod=brk,numCats=5, 
               addLegend=T, missingCountryCol="grey", nameColumnToHatch="missing")

# Label panel
mtext("a. Indicator A.2 reported by Parties " ,cex=1.6, side = 3, adj = 0, line = -0.75,font=2)
mtext("Headline Indicator A.2 (Extent of natural ecosystems)" ,cex=1.6, side = 1, adj = 0.5, line = -2.5,font=1)

# Add legend
legend(-190,-25, c("Did not submit National Report", "Did not report Indicator A.2"), 
	pt.cex=2,cex=1.1,    pt.bg="grey", pch = 22)

legend(-190,-25, c("Did not submit National Report", "Did not report Indicator A.2"), 
	pt.cex=2,cex=1.1,    col=c("white",NA), pch = 7, text.col="transparent", bty="n")

##########################################################################################
# Panel B
par(mai=c(0,0.1,0.4,0.1))

# Creat dataframe
df <- data.frame(
  country=names(prop),#WRI$ISO3,
  index = as.numeric(prop))#as.numeric(WRI$class_1_proportion))
df$index[which(df$index=="NaN")]<- NA
# Spatial join
m <- joinCountryData2Map(df, joinCode="ISO3", nameJoinColumn="country")
m <- m[row.names(m) != 'Antarctica', ]

# Creat map
mapCountryData(m, nameColumnToPlot="index",mapTitle="", colourPalette = ramp, 
               borderCol="white", lwd=0.85, catMethod=brk,numCats=5,
               addLegend=F, missingCountryCol="lightgrey")
# Label panel
mtext("b. Indicator A.2 from SBTN Natural Lands Map" ,cex=1.6, side = 3, adj = 0, line = -0.75,font=2)
dev.off()

#######################################################################################################
#######################################################################################################

# Summary statistics for country-reported data
summary(GBF$A2)
# Summary statistics for SBTN data
summary(as.numeric(prop))
