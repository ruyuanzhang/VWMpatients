# Delay-estimation visual working memory task

This is the matlab code repository for delayed-estimation visual working memory (TMVWM) project. The main contributor for this project is [Ru-Yuan Zhang](ruyuanzhang@gmail.com).

This code is mainly for patient studies. In a single session, we tested many set size levels and several trials.  

## History

* 2020/10/21, 
  * RZ add to 2 rest during the exp
  * RZ add 'esc' as the key to quit
  * RZ update data analysis script
* 2020/10/16, RZ fixed the Mac retin
* 2020/10/12, RZ add multiple set size levels 
* 2019/12/05, RZ saved all non-target color in a trial  
* 2019/10/25 RZ add 4 seconds response constraint, otherwise the trial will be added at the end.
* 2019/09/11 RZ fixed the bugs 
* 2019/07/01 RZ created the github repository


## Instructions of running experiments
### Preparation
* Please download Ru-Yuan Zhang's utility function repository https://github.com/ruyuanzhang/RZutil, and add it to your matlab path
* You should know your monitor physical size [height cm, width cm] and resolution [height px, widwth px].
* Please keep the view distance roughly 50cm.

### Running experiment

1. For each run, simply type the subject's initial to run the experiment. 

~~~matlab
>> VWM_rect_new_rz.m
Please the subject initial (e.g., RYZ or RZ)?: RZ
~~~


2. Data will be automatically saved with time stamp.

### Research plan


# Research progress and thoughts

