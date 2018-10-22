subplot(2,1,1)
X4=1:672;
Y1=DterministicOutputdata4144.Original_load_kw(1345:2016);
area(X4,Y1) ;
hold on 
Y3=DterministicOutputdata4144.Net_load_w_ESS_kw(1345:2016);
X5= 1:672 ;
Y2=DterministicOutputdata4144.ESS_injection_kw(1345:2016);
plotyy(X4,Y3,X5,Y2)
legend ( 'Original Load' , ' Net Load' , 'Ess Injection' )
set(gca, 'XTick', [0 96  192 288 384 480 576 672])
xlabel('x axis')
ylabel('y axis')
subplot(2,1,2)
plot(ESS_week_soc);
set(gca, 'XTick', [0 96  192 288 384 480 576 672])
legend ( 'SoC' )