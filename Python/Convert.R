resave <- function(file){
  e <- new.env(parent = emptyenv())
  load(file, envir = e)
  objs <- ls(envir = e, all.names = TRUE)
  for(obj in objs) {
    .x <- get(obj, envir =e)
    message(sprintf('Saving %s as %s.csv', obj,obj) )
    write.csv(.x, file = paste0('/home/waco001/Desktop/SMFG/Python/CSV/',obj, '.csv'))
  }
}

resave('/home/waco001/Desktop/SMFG/Python/TestDataForAbhishek.RData')
