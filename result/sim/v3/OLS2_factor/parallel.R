load("myseeds.RData")
nsim = length(myseeds)
for (i in 1:nsim){
	system(paste0('sbatch -o main.out -t 00:30:00 --wrap="Rscript sim_OLS2_factor.R myseed=', myseeds[i], '"'))
}
