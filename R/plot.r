##' Plot
##'
##' Plot a syndromic (\code{syndromicD} or \code{syndromicW}) object.
##'
##'
##' @section Methods: \describe{
##' \item{\code{signature(object = "syndromicW")}}{
##' Show information for the syndromic object.
##' }
##' }
##' @param x a syndromic object
##' @param syndromes an optional parameter, if not specified, all
##' columns in the slot observed (or baseline of the
##'  \code{syndromic} object
##' will be used. The user can choose to restrict the plotting to 
##' a few syndromic groups listing their name or column position
##' in the observed matrix. See examples.
##' @param window the number of time points to plot, always finishing at the 
##' last time point recorded.
##' @param baseline whether to plot the baseline, by default equal to TRUE.
##' @param UCL the dimension of the slot UCL, from the syndromic object, from which
##' the user wants to plot the UCL. Set to NULL or to 0 if it is not desired to plot the UCL.
##' @param algorithms an optional parameter specifying which dimensions
##' of the alarm slot to plot. If not specified (NULL), all are plotted. If set 
##' to zero, none are plotted.
##' @param limit an optional parameter establishing a score above which
##' alarms are considered worth of notice. Notice that this is not a
##' statistical value, but a score equivalent to the number of algorithms
##' employed and the number of limits set to them. See the tutorial for details.
##' @keywords methods
##' @import methods
##' @import ISOweek
##'
##' @rdname plot-methods
##' @docType methods
##' 


##' @rdname plot-methods
##' @export

setMethod("plot","syndromicD",
                      function (x,
                      syndromes=NULL,
                      window=365,
                      baseline=TRUE,
                      UCL=1,
                      algorithms=NULL,
                      limit=1)

                      {
                        
                        ##check that syndromes is valid
                        if (class(syndromes)=="NULL"){
                          syndromes <- colnames(x@observed)
                        }
                        #       else{
                        #         if (class(syndromes)!="character"&&class(syndromes)!="integer") {
                        #     stop("if provided, argument syndromes must be a character or numeric vector")
                        #           }
                        #          }
                        
                        
                        ##check that valid dates are entered
                        if (dim(x@observed)[1]!=dim(x@dates)[1]){
                          stop("valid data not found in the slot dates")
                        }
                        
                        
                        #make sure syndrome list is always numeric
                        #even if user gives as a list of names
                        if (is.numeric(syndromes)) {
                          syndromes.num <- syndromes
                        }else{
                          syndromes.num <- match(syndromes,colnames(x@observed))
                        }
                        
                        #window of plotting
                        end<-dim(x@observed)[1]
                        start<-max(1, end-window+1)
                        
                        algo.names<-dimnames(x@alarms)[[3]]
                        #algorithms to be used
                        if (class(algorithms)=="NULL") {
                          alarms.array <- x@alarms
                          algorithms <- 1:dim(x@alarms)[3]
                        }else{
                          alarms.array <- x@alarms[,,algorithms,drop=FALSE]
                        }
                        
                        
                        
                        if(length(algorithms)==1&&algorithms!=0){
                          n.algos <- 1
                        }else{
                          n.algos<-dim(alarms.array)[3]
                        }
                        alarms.sum<-apply(alarms.array,MARGIN=c(1,2),FUN="sum",na.rm=TRUE)
                        
                        
                        
                        #set plot
                        par(mfrow=c(length(syndromes.num),1),mar=c(4,4,2,4))
                        
                        for (s in syndromes.num){      
                          
                          #set limits
                          ymax<-max(x@observed[start:end,s])
                          ymin<-min(x@observed[start:end,s])
                          
                          ymax.bar <- max(1,max(alarms.sum[,s]))
                          x.date <- x@dates[start:end,1]
                          
                          #set empty bar chart
                          par(yaxt="s")
                          plot(y=rep(0,length(x.date)),x=1:length(x.date), 
                               ylim=c(0,ymax.bar), type="l", yaxt="n",xaxt="n",
                               col="white",col.lab="white")
                          if (n.algos>0){
                            Axis(side=4,at=1:ymax.bar)        
                            mtext("Final alarm score", side = 4, line=2)
                          }
                          
                          #set grey bar of non-significant alarms
                          if (class(limit)!="NULL"){
                            polygon(x=c(min(0), min(0), length(x.date), length(x.date)), 
                                    y=c(0,limit,limit,0),col="lightgray",border=NA)
                          }
                          
                          if(n.algos>0){
                            legend (x=1, y=ymax.bar, title="Alarm Algorithm", 
                                    algo.names[algorithms],pch=18,col=2:(2+n.algos-1))
                          }
                          
                          
                          
                          #plot observed data
                          par(new=T, yaxt="n")
                          plot(x@observed[start:end,s],x=x.date, yaxt="s", 
                               ylim=c(ymin,ymax), type="l", 
                               main=colnames(x@observed)[s],xlab="Days", ylab="Events")
                          
                          
                          if (n.algos==1){
                            par(new=T, yaxt="n")
                            barplot(alarms.array[start:end,s,1], 
                                    ylim=c(0,ymax.bar), border=2+a-1,col=2+a-1)
                          }else{
                            
                            if (n.algos>0){
                              for (a in 1:n.algos){
                                par(new=T, yaxt="n")
                                barplot(apply(as.matrix(alarms.array[start:end,s,(1+a-1):(n.algos)]),FUN="sum",
                                              MARGIN=1,na.rm=TRUE), 
                                        ylim=c(0,ymax.bar), border=2+a-1,col=2+a-1)
                              }
                            }
                            
                          }
                          
                          par(new=T, yaxt="n")
                          plot(x@observed[start:end,s],x=x.date, 
                               ylim=c(ymin,ymax), type="l", lwd=1.5,  col.lab=0, ylab="",xlab="") 
                          
                          if (baseline==TRUE){
                            lines(x=x.date, y=x@baseline[start:end,s],col="blue")
                          }
                          
                          if (class(UCL)!="NULL"&&UCL>0){
                            lines(x=x.date, y=x@UCL[start:end,s,UCL], col="red", lty=2)
                          }
                          
                        }
                        
                        
                        
                      }
)

##' @rdname plot-methods
##' @export
setMethod("plot","syndromicW",
          function (x, syndromes=NULL,
                    window=52,
                    baseline=TRUE,
                    UCL=1,
                    algorithms=NULL,
                    limit=NULL)
          {
            
            
            
            ##check that syndromes is valid
            if (class(syndromes)=="NULL"){
              syndromes <- colnames(x@observed)
            }
            #       else{
            #         if (class(syndromes)!="character"&&class(syndromes)!="numeric") {
            #     stop("if provided, argument syndromes must be a character or numeric vector")
            #           }
            #         }
            
            
            ##check that valid dates are entered
            if (dim(x@observed)[1]!=dim(x@dates)[1]){
              stop("valid data not found in the slot dates")
            }
            
            
            
            
            #make sure syndrome list is always numeric
            #even if user gives as a list of names
            if (is.numeric(syndromes)) {
              syndromes.num <- syndromes
            }else{
              syndromes.num <- match(syndromes,colnames(x@observed))
            }
            
            #window of plotting
            end<-dim(x@observed)[1]
            start<-max(1, end-window+1)
            
            
            if (dim(x@alarms)[1]!=0){
              
              algo.names<-dimnames(x@alarms)[[3]]
              #algorithms to be used
              if (class(algorithms)=="NULL") {
                alarms.array <- x@alarms
                algorithms <- 1:dim(x@alarms)[3]
              }else{
                alarms.array <- x@alarms[,,algorithms,drop=FALSE]
              }
              
              
              
              if(length(algorithms)==1&&algorithms!=0){
                n.algos <- 1
              }else{
                n.algos<-dim(alarms.array)[3]
              }
              alarms.sum<-apply(alarms.array,MARGIN=c(1,2),FUN="sum",na.rm=TRUE)
            }
            
            
            #set plot
            par(mfrow=c(length(syndromes.num),1),mar=c(4,4,2,4))
            
            for (s in syndromes.num){      
              
              
              if (dim(x@alarms)[1]==0){
                ymax<-max(x@observed[start:end,s])
                x.date <- ISOweek2date(x@dates[start:end,1])
                
                #plot observed data
                plot(x@observed[start:end,s],x=x.date, yaxt="s", 
                     ylim=c(0,ymax), type="l", 
                     main=colnames(x@observed)[s],xlab="Weeks", ylab="Events")
                
                
                if (baseline==TRUE){
                  lines(x=x.date, y=x@baseline[start:end,s],col="blue")
                }
                
              }else{
                
                #set limits
                ymax<-max(x@observed[start:end,s])
                ymax.bar <- max(1,max(alarms.sum[,s])) 
                x.date <- ISOweek2date(x@dates[start:end,1])
                
                #set empty bar chart
                par(yaxt="s")        
                plot(y=rep(0,length(x.date)),x=1:length(x.date), 
                     ylim=c(0,ymax.bar), type="l", yaxt="n",xaxt="n",
                     col="white",col.lab="white")
                if (n.algos>0){
                  Axis(side=4,at=1:ymax.bar)        
                  mtext("Final alarm score", side = 4, line=2)
                }
                
                #set grey bar of non-significant alarms
                if (class(limit)!="NULL"){
                  polygon(x=c(min(0), min(0), length(x.date), length(x.date)), 
                          y=c(0,limit,limit,0),col="lightgray",border=NA)
                }
                
                
                if(n.algos>0){
                  legend (x=1, y=ymax.bar, title="Alarm Algorithm", 
                          algo.names[algorithms],pch=18,col=2:(2+n.algos-1))
                  
                }
                
                
                
                #plot observed data
                par(new=T, yaxt="n")
                plot(x@observed[start:end,s],x=x.date, yaxt="s", 
                     ylim=c(0,ymax), type="l", 
                     main=colnames(x@observed)[s],xlab="Weeks", ylab="Events")
                
                
                if (n.algos==1){
                  par(new=T, yaxt="n")
                  barplot(alarms.array[start:end,s,1], 
                          ylim=c(0,ymax.bar), border=2+a-1,col=2+a-1)
                }else{
                  
                  if (n.algos>0){
                    for (a in 1:n.algos){
                      par(new=T, yaxt="n")
                      barplot(apply(as.matrix(alarms.array[start:end,s,(1+a-1):(n.algos)]),FUN="sum",
                                    MARGIN=1,na.rm=TRUE), 
                              ylim=c(0,ymax.bar), border=2+a-1,col=2+a-1)
                    }
                  }
                  
                }
                
                par(new=T, yaxt="n")
                plot(x@observed[start:end,s],x=x.date, 
                     ylim=c(0,ymax), type="l", lwd=1.5,  col.lab=0, ylab="",xlab="") 
                
                if (baseline==TRUE){
                  lines(x=x.date, y=x@baseline[start:end,s],col="blue")
                }
                
                if (class(UCL)!="NULL"&&UCL>0){
                  lines(x=x.date, y=x@UCL[start:end,s,UCL], col="red", lty=2)
                }
                
              }
              
            }
            
          }
)
