library(lme4)
library(broom.mixed)

dat<-read.csv('data_subset_norm.csv')

# create variables with correct data types
dat$year<-unlist(dat[c('year')])
dat$can_bics_n<-unlist(dat[c('can_bics_n')])
dat$acs_idx_emp<-unlist(dat[c('acs_idx_emp')])
dat$bike_total<-unlist(dat[c('bike_total')])
dat$grouped_counterpoint_id<-unlist(dat[c('grouped_counterpoint_id')])
dat$count_session_label<-unlist(dat[c('count_session_label')])
dat$total_time_hours<-unlist(dat[c('total_time_hours')])


# relevel count session so that weekday morning is the reference category
dat$countsession <- factor(dat$count_session_label, 
                            levels=c("weekday_morning",
                                     "weekday_lunch",
                                     "weekday_afternoon",
                                     "weekday_late_afternoon",
                                     "weekend_afternoon"))

# create categorical canbics variables
dat$canbics <- factor(dat$can_bics_n, 
                      levels = c("0",
                                 "1",
                                 "2",
                                 "3",
                                 "4",
                                 "5"))


# model without random effect for each observation
m_init<-glmer(bike_total # use total counts as response
              ~ acs_idx_emp # rescaled to IQR
              + year # scaled to 2021 = 0
              + canbics # range 0-5, categorical
              + countsession
              + (1|grouped_counterpoint_id), # random effect of count site
              data=dat,
              offset=log(total_time_hours), # offset is count time
              family = "poisson") # poisson for counts

# convergence warning but OK with Nelder-Mead
m<-glmer(bike_total # use total counts as response
                 ~ acs_idx_emp # rescaled to IQR
                 + year # scaled to 2021 = 0
                 + canbics # range 0-5, categorical
                 + countsession
                 + (1|grouped_counterpoint_id) # random effect of count site
                 + (1|index),  # a random effect for each observation to control overdispersion
                 data=dat,
                 offset=log(total_time_hours), # offset is count time
                 family = "poisson") # poisson for counts



# save results to csv
write.csv(tidy(m_init),
          "glmm_results_init.csv", 
          row.names=FALSE)

write.csv(tidy(m),
          "glmm_results.csv", 
          row.names=FALSE)

# pearson residuals
write.csv(residuals(m_init, method="pearson"),
          "resids_pearson_init.csv", 
          row.names=FALSE)

write.csv(residuals(m, method="pearson"),
          "resids_pearson.csv", 
          row.names=FALSE)

#calculate confidence intervals
conf_wald<-confint(m, method="Wald", level=0.95)

write.csv(conf_wald, 
          "confint_wald.csv", 
          row.names=FALSE)

# also compute bootstrap CI and compare - bootstrap is very slow
conf_boot<-confint(m, method="boot", nsim=500, level=0.95)

write.csv(conf_boot, 
          "confint_boot.csv", 
          row.names=FALSE)    


# SEPARATE MODELS BY CAN-BICS CLASS

cbics_n<-c(0,1,2,3,4,5)

for (n in cbics_n) {
  
  dat_c<-read.csv(sprintf('data_subset_can_bics_%s.csv', n))
  
  dat_c$countsession <- factor(dat_c$count_session_label, 
                               levels=c("weekday_morning",
                                        "weekday_lunch",
                                        "weekday_afternoon",
                                        "weekday_late_afternoon",
                                        "weekend_afternoon"))
  
  m_canbics<-glmer(bike_total # use total counts as response
                    ~ acs_idx_emp # rescaled to IQR
                    + year # scaled to 2021 = 0
                    + countsession 
                    + (1|grouped_counterpoint_id) # random effect of count site
                    + (1|index),  # a random effect for each observation to control overdispersion
                    data=dat_c,
                    offset=log(total_time_hours), # offset is count time
                    family = "poisson") # poisson for counts
  
  summary(m_canbics)
  
  write.csv(tidy(m_canbics),
            sprintf("glmm_canbics%s_results.csv", n), 
            row.names=FALSE)
  
  conf_canbics<-confint(m_canbics, method="Wald", level=0.95)
  
  write.csv(conf_canbics, 
            sprintf("confint_canbics%s.csv", n),
            row.names=FALSE)
  
  conf_canbics_boot<-confint(m_canbics, method="boot", nsim=500, level=0.95)
  
  write.csv(conf_canbics_boot, 
            sprintf("confint_canbics%s_boot.csv", n),
            row.names=FALSE)

}
