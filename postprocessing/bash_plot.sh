ferret -batch wj_aug_fig1.ps -script caller_plot_wj_fullvec_perMod.jnl
convert -density 400 wj_aug_fig1.ps -rotate 90 -resize 100% wj_aug_fig1.gif

ferret -batch ua_6010_fig1.ps -script plot_vert.jnl 1
convert -density 400 ua_6010_fig1.ps -rotate 90 -resize 100% ua_6010_fig1.gif

ferret -batch ua_6015_fig1.ps -script plot_vert.jnl 2
convert -density 400 ua_6015_fig1.ps -rotate 90 -resize 100% ua_6015_fig1.gif

ferret -batch tmp_6010_fig1.ps -script plot_tmp.jnl 1
convert -density 400 tmp_6010_fig1.ps -rotate 90 -resize 100% tmp_6010_fig1.gif

ferret -batch tmp_6015_fig1.ps -script plot_tmp.jnl 2
convert -density 400 tmp_6015_fig1.ps -rotate 90 -resize 100% tmp_6015_fig1.gif

