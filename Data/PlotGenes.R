##
## Plots one to many genes given on the command line to 3 files in the specified output directory
##
outputPlotsTo = "/home/waco001/Desktop/SMFG/Data/StuffForAbhishek/"
load("/home/waco001/Desktop/SMFG/Data/TestDataForAbhishek.RData")


##
## Define and check inputs:
##
args<-commandArgs(TRUE)
#args = c("1","CYC1","PIAS2","LPAR2")
stopifnot(length(args) >= 2)
if(length(args) >= 2){
  request_UID = args[1]
  geneIDs = args[-1]
}else{ 
  ## If no gene IDs are specified, throw an error message
}


##
## Load dependencies
##
if(!"plyr" %in% rownames(installed.packages())) { install.packages("plyr",repos='http://cran.us.r-project.org') }
if(!"ggplot2" %in% rownames(installed.packages())) { install.packages("gplots",repos='http://cran.us.r-project.org') }
if(!"reshape2" %in% rownames(installed.packages())) { install.packages("reshape2",repos='http://cran.us.r-project.org') }
require(plyr)
require(ggplot2)
require(reshape2)



##
## Function to search for the geneID from a single input query
##
getGeneID = function(searchTerm, annotation=annotation.gencodeM4){
  annotation = annotation[, colnames(annotation) %in% c("geneID","transcriptID","geneName","transcriptName")]
  toReturn = c(searchTerm,NA,NA)
  if(toupper(searchTerm) %in% toupper(annotation$geneID)){
    tmp = unique(annotation[toupper(annotation$geneID) %in% toupper(searchTerm), colnames(annotation) %in% c("geneID","geneName")])
    toReturn[2] = tmp$geneID
    toReturn[3] = tmp$geneName
  }else if(toupper(searchTerm) %in% toupper(annotation$geneName)){
    tmp = unique(annotation[toupper(annotation$geneName) %in% toupper(searchTerm), colnames(annotation) %in% c("geneID","geneName")])
    toReturn[2] = tmp$geneID
    toReturn[3] = tmp$geneName
  }else if(toupper(searchTerm) %in% toupper(annotation$transcriptID)){
    tmp = unique(annotation[toupper(annotation$transcriptID) %in% toupper(searchTerm), ])
    toReturn[2] = tmp$geneID
    toReturn[3] = tmp$geneName
  }else if(toupper(searchTerm) %in% toupper(annotation$transcriptName)){
    tmp = unique(annotation[toupper(annotation$transcriptName) %in% toupper(searchTerm), ])
    toReturn[2] = tmp$geneID
    toReturn[3] = tmp$geneName
  }else{
    ## no hits to full query, try partial matches with grep
    hit = unique(annotation[grep(searchTerm, annotation$geneID, ignore.case=T), colnames(annotation) %in% c("geneID","geneName"), drop=F])
    if(nrow(hit) > 0){
      toReturn = matrix(ncol=3,nrow=nrow(hit))
      toReturn[,1] = rep(searchTerm, nrow(hit))
      toReturn[,2] = hit$geneID
      toReturn[,3] = hit$geneName
    }else{
      hit = unique(annotation[grep(searchTerm, annotation$transcriptID, ignore.case=T), , drop=F])
      if(nrow(hit) > 0){
        toReturn = matrix(ncol=3,nrow=nrow(hit))
        toReturn[,1] = rep(searchTerm, nrow(hit))
        toReturn[,2] = hit$geneID
        toReturn[,3] = hit$geneName
      }else{
        hit = unique(annotation[grep(searchTerm, annotation$geneName, ignore.case=T), colnames(annotation) %in% c("geneID","geneName"), drop=F])
        if(nrow(hit) > 0){
          toReturn = matrix(ncol=3,nrow=nrow(hit))
          toReturn[,1] = rep(searchTerm, nrow(hit))
          toReturn[,2] = hit$geneID
          toReturn[,3] = hit$geneName
        }else{
          hit = unique(annotation[grep(searchTerm, annotation$transcriptName, ignore.case=T), , drop=F])
          if(nrow(hit) > 0){
            toReturn = matrix(ncol=3,nrow=nrow(hit))
            toReturn[,1] = rep(searchTerm, nrow(hit))
            toReturn[,2] = hit$geneID
            toReturn[,3] = hit$geneName
          }else{
            cat("Warning: Unable to find '",searchTerm,"'\n")
          }
        }
      }
    }
  }
  return(toReturn)
}

##
## Function to get all geneIDs from multiple queries
##
getGeneIDs = function(searchTerms, annotation=annotation.gencodeM4){
  #searchTerms = c("FEZF2","BCL11B")
  result = NULL
  for(i in 1:length(searchTerms)){
    result = rbind(result, getGeneID(searchTerms[i], annotation))
  } 
  colnames(result) = c("InputQuery","GeneID","GeneName")
  return(as.data.frame(result, stringsAsFactors=F))
}



##
## Plot mouse cell-type data
##
plotGene_cellTypeSpecificity = function(genes, data=exprs.gene.lognorm, annotation=annotation.gencodeM4, celltypes=celltypes.all, ncol=NULL, outputPath=NULL){
  
  gene = getGeneIDs(genes, annotation)$GeneName
  
  #unique(annotation[grep("HPCA",annotation$geneName, ignore.case=T), ]$geneName)
  tmp.ann = unique(annotation[annotation$geneName %in% gene, c(1,5:6,8:10)])
  #tmp.exprs = exprs.gene.regionOnly.log[rownames(exprs.gene.regionOnly.log) %in% tmp.ann$geneID, ,drop=F]
  tmp.exprs = melt(cbind(tmp.ann, data[match(tmp.ann$geneID, rownames(data)), ,drop=F]))
  #colnames(tmp.exprs) = c("geneID","sampleID","Expression")
  
  tmp.exprs = cbind(tmp.exprs, matrix(unlist(strsplit(as.character(tmp.exprs$variable),":")),ncol=2,byrow=T)[,1,drop=F])
  colnames(tmp.exprs)[-c(1:6)] = c("sampleID","Expression","CellType")
  
  celltypeOrder = c("Colgalt2_pyramidal_cortical_neurons","S100a10_pyramidal_cortical_neurons","callosal_projection_neurons","corticothalamic_projection_neurons","subcerebral_projection_neurons","D1_striatal_neurons","ChAT_cholinergic_striatal_neurons","neuron","astrocyte","endothelial","microglia","oligodendrocyte_precursor","newly_formed_oligodendrocyte","myelinating_oligodendrocyte")
  tmp.exprs$CellType = factor(as.character(tmp.exprs$CellType), levels=celltypeOrder)
  tmp.exprs = cbind(tmp.exprs, celltypes[match(as.character(tmp.exprs$CellType), celltypes[,1]), 2:3])
  
  tmp.exprs = cbind(tmp.exprs, isNonCoding=rep(T,nrow(tmp.exprs)))
  tmp.exprs$isNonCoding[tmp.exprs$geneType %in% "protein_coding"] = F
  
  #ggplot(tmp.exprs, aes(y=10^Expression, x=CellType, colour=paste(geneName," (",geneID,")",sep=""), group=geneName)) +geom_point(alpha=1, size=5) +theme(axis.text.x=element_text(angle=90, hjust=1, vjust=0.5)) +facet_wrap(~geneName, scales="free_y")+theme(legend.position="none")
  p = ggplot(tmp.exprs, aes(y=10^Expression, x=CellType, colour=level2, group=geneName, shape=isNonCoding)) +geom_point(alpha=1, size=5) +theme(axis.text.x=element_text(angle=90, hjust=1, vjust=0.5)) +facet_wrap(~geneName, scales="free_y", ncol=ncol)+theme(legend.position="none") +ylab("TPM")
  
  if(!is.null(outputPath)){ pdf(outputPath, width=7,height=7) }
  facetAdjust(p)
  if(!is.null(outputPath)){ dev.off() }
}



##
## Plot human organ-level data
##
plotGene_Bodymap = function(genes, data=bodymap.exprs.tpm.norm.geneLevel, annotation=annotation.gencode21, sampleInfo=sampleInfo.bodymap, log_y=F, displayLegend=T, plotSex=F, ncol=NULL, outputPath=NULL){
  
  gene = getGeneIDs(genes, annotation)$GeneName
  
  tmp.ann = unique(annotation[annotation$geneName %in% gene, c(1,5:6,8:10)])
  
  tmp.exprs = melt(cbind(tmp.ann, data[match(tmp.ann$geneID, rownames(data)), ]))
  tmp.exprs = cbind(tmp.exprs, sampleInfo[match(tmp.exprs$variable, sampleInfo$Tissue), ])
  colnames(tmp.exprs)[7:8] = c("SampleID","Expression")
  
  if(log_y)
    p = ggplot(tmp.exprs, aes(y=Expression+0.001, x=Tissue, colour=paste(geneName," (",geneID,")",sep=""), group=geneName)) +geom_point(alpha=1, size=3) +scale_y_log10() +theme(axis.text.x=element_text(angle=90, hjust=1, vjust=0.5))
  else{
    p = ggplot(tmp.exprs, aes(y=Expression, x=Tissue, colour=Tissue, group=geneName)) +geom_point(alpha=1, size=5) +theme(axis.text.x=element_text(angle=90, hjust=1, vjust=0.5))
    #p = ggplot(tmp.exprs, aes(bin=Expression, x=Tissue, colour=paste(geneName," (",geneID,")",sep=""), group=geneName)) +geom_bar() +theme(axis.text.x=element_text(angle=90, hjust=1, vjust=0.5))
  }
  
  #if(!displayLegend)
  #  p = p+theme(legend.position="none")
  
  if(length(unique(tmp.exprs$geneID)) == 1){
    if(plotSex){
      p = p+facet_grid(~Sex, scales="free_x")
    }else{
      p = p+facet_wrap(~geneName, scales="free_y", ncol=ncol)+theme(legend.position="none")
    }
  }else{
    p = p+facet_wrap(~geneName, scales="free_y", ncol=ncol)+theme(legend.position="none")
  }
  
  if(!is.null(outputPath)){ pdf(outputPath, width=7,height=7) }
  facetAdjust(p)
  if(!is.null(outputPath)){ dev.off() }
  
}



##
## Plot human brain development data
##
plotGene_Brainspan = function(genes, data=brainspan.rpkms.mRNA, annotation=brainspan.featureInfo.rnaseq, annotation.official=annotation.gencode21, sampleInfo=sampleInfo.rnaseq, keepRegions=c("CBC","M1C","MD","S1C","STR","A1C","AMY","ITC","OFC","STC","HIP","IPC","MFC","V1C","DFC","VFC","NCX"), log_y=F, displayLegend=T, plotSex=F, title=NULL, collapseRegion=c("cortex","lobe","none"), outputPath=NULL){
  
  gene = getGeneIDs(genes, annotation.official)$GeneName
  
  tmp.ann = annotation[annotation$GeneName %in% gene, ]
  #tmp.ann = tmp.ann[tmp.ann$GeneName %in% rownames(data), ]
  
  tmp.exprs = melt(cbind(tmp.ann, data[match(rownames(tmp.ann), rownames(data)), ,drop=F]))
  tmp.exprs = cbind(tmp.exprs, sampleInfo[match(tmp.exprs$variable, rownames(sampleInfo)), ], stringsAsFactors=F)
  colnames(tmp.exprs)[5:6] = c("SampleID","Expression")
  
  ## Modify region plotting
  if(length(collapseRegion) > 1){ collapseRegion = collapseRegion[1] }
  cortexRegions = c("DFC","M1C","MFC","OFC","VFC","IPC","S1C","A1C","STC","ITC","V1C")
  tmp.exprs$Region = as.character(tmp.exprs$Region)
  tmp.exprs = tmp.exprs[tmp.exprs$Region %in% keepRegions, ]
  
  if(collapseRegion == "cortex"){
    tmp.exprs$Region[tmp.exprs$Region %in% cortexRegions] = "NCX"
    tmp.exprs$Region = factor(tmp.exprs$Region, levels=c("NCX","HIP","AMY","STR","MD","CBC"))
  }else if(collapseRegion == "lobe"){
    tmp.exprs$Region[tmp.exprs$Region %in% c("DFC","M1C","MFC","OFC","VFC")] = "FC"
    tmp.exprs$Region[tmp.exprs$Region %in% c("IPC","S1C")] = "PC"
    tmp.exprs$Region[tmp.exprs$Region %in% c("A1C","STC","ITC")] = "TC"
    tmp.exprs$Region[tmp.exprs$Region %in% c("V1C")] = "OC"
    tmp.exprs$Region = factor(tmp.exprs$Region, levels=c("FC","PC","TC","OC","HIP","AMY","STR","MD","CBC"))
  }else{
    tmp.exprs$Region = factor(tmp.exprs$Region, levels=c(cortexRegions,"HIP","AMY","STR","MD","CBC"))
  }
  
  dim(tmp.exprs)
  
  #if(log_y){
  #  p = ggplot(tmp.exprs, aes(y=Expression+0.001, x=Days, colour=paste(GeneName," (",GeneName,")",sep=""), group=GeneName)) +geom_point(alpha=1, size=1) +stat_smooth(method=loess,na.rm=T, size=2, alpha = 0.2) +scale_x_log10() +scale_y_log10()
  #}else{
    p = ggplot(tmp.exprs, aes(y=Expression, x=Days, colour=paste(GeneName," (",GeneID,")",sep=""), group=GeneName)) +geom_point(alpha=1, size=1) +stat_smooth(method=loess,na.rm=T, size=1, alpha = 0.2) +scale_x_log10()
  #}
  
  p = p +theme(legend.position="none") +facet_grid(GeneName~Region, scales="free_y") +geom_vline(xintercept=270,linetype="longdash", alpha=0.25)
  
  #if(!is.null(title)){
  #  p = p +ggtitle(title) +theme(plot.title=element_text(size=20, face="bold", vjust=2))
  #}
  
  #facetAdjust(p)
  if(!is.null(outputPath)){ pdf(outputPath, width=7,height=7) }
  print(p)
  if(!is.null(outputPath)){ dev.off() }
}




##
## Function to adjust some of the plots
##
library(grid)
# pos - where to add new labels
# newpage, vp - see ?print.ggplot
facetAdjust <- function(x, pos = c("up", "down"), newpage = is.null(vp), vp = NULL){
  # part of print.ggplot
  ggplot2:::set_last_plot(x)
  if(newpage)
    grid.newpage()
  pos <- match.arg(pos)
  p <- ggplot_build(x)
  gtable <- ggplot_gtable(p)
  # finding dimensions
  dims <- apply(p$panel$layout[2:3], 2, max)
  nrow <- dims[1]
  ncol <- dims[2]
  # number of panels in the plot
  panels <- sum(grepl("panel", names(gtable$grobs)))
  space <- ncol * nrow
  # missing panels
  n <- space - panels
  # checking whether modifications are needed
  if(panels != space){
    # indices of panels to fix
    idx <- (space - ncol - n + 1):(space - ncol)
    # copying x-axis of the last existing panel to the chosen panels 
    # in the row above
    gtable$grobs[paste0("axis_b",idx)] <- list(gtable$grobs[[paste0("axis_b",panels)]])
    if(pos == "down"){
      # if pos == down then shifting labels down to the same level as 
      # the x-axis of last panel
      rows <- grep(paste0("axis_b\\-[", idx[1], "-", idx[n], "]"), 
                   gtable$layout$name)
      lastAxis <- grep(paste0("axis_b\\-", panels), gtable$layout$name)
      gtable$layout[rows, c("t","b")] <- gtable$layout[lastAxis, c("t")]
    }
  }
  # again part of print.ggplot, plotting adjusted version
  if(is.null(vp)){
    grid.draw(gtable)
  }
  else{
    if (is.character(vp)) 
      seekViewport(vp)
    else pushViewport(vp)
    grid.draw(gtable)
    upViewport()
  }
  invisible(p)
}




##
## Finally, do the plots
##
plotGene_cellTypeSpecificity(geneIDs, outputPath=paste(outputPlotsTo,"/",request_UID,"_celltypes.pdf",sep=""))
plotGene_Bodymap(geneIDs, outputPath=paste(outputPlotsTo,"/",request_UID,"_bodymap.pdf",sep=""))
plotGene_Brainspan(geneIDs, outputPath=paste(outputPlotsTo,"/",request_UID,"_brainspan.pdf",sep=""))

#plotGene_cellTypeSpecificity(geneIDs)
#plotGene_Brainspan(geneIDs)
#plotGene_Bodymap(geneIDs)
