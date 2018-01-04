% function plot7d()
% clear 
% close all;
% clc
% 
% amp_recovery(n,p,m,l,v,x,o,w,f);
%
%
% load amp_recovery_mean
% p,l,v,x,o,w,f 
% load param

% WM_dimensional_mean;
mode=5; 
WM_plot7d_init;


%% Create Sliders and Edit boxes 
%  for unit-wavelength (l)
tl = uicontrol('style','text', 'str','unit-wavelength (%):', 'fontsize',14, 'unit','norm');
set(tl,'pos',[.15 .18 .1 .03])

nl = size(param.wavelength_range,2);
sll = uicontrol('style','slider','Tag','l-slide', ...
    'Min', 1, 'Max', nl, 'Value', 1, 'SliderStep',[1/nl 10/nl], ...
    'unit','norm');
set(sll,'pos',[.25 .175 .5 .03])

edl = uicontrol('style','edit','Tag','l-edit', 'str','1','fontsize',14,'unit','norm');
set(edl,'pos',[.8 .18 .05 .03])

%  for MEAN PERIOD (p)
tp = uicontrol('style','text', 'str','Mean Period (ms):', 'fontsize',14, 'unit','norm');
set(tp,'pos',[.1475 .08 .1 .03])

np = size(param.period_range,2);
slp = uicontrol('style','slider','Tag','p-slide', ...
    'Min', 1, 'Max', np, 'Value', 1, 'SliderStep',[1/np 1/np], ...
    'unit','norm');
set(slp,'pos',[.25 .075 .5 .03])

edp = uicontrol('style','edit','Tag','p-edit', 'str','1','fontsize',14,'unit','norm');
set(edp,'pos',[.8 .08 .05 .03])

%  for temporal ORDER of jitter (o)
to = uicontrol('style','text', 'str','Temporal order of Jitter:', 'fontsize',14, 'unit','norm');
set(to,'pos',[.085 .13 .2 .03])

no = size(param.order,1);
slo = uicontrol('style','slider','Tag','o-slide', ...
    'Min', 1, 'Max', no, 'Value', 1, 'SliderStep',[1/no 1/no], ...
    'unit','norm');
set(slo,'pos',[.25 .125 .5 .03])

edo = uicontrol('style','edit','Tag','o-edit', 'str','1','fontsize',14,'unit','norm');
set(edo,'pos',[.8 .13 .05 .03])

%  for WAVEFORMS (v)
tv = uicontrol('style','text', 'str','Waveform:', 'fontsize',14, 'unit','norm');
set(tv,'pos',[.165 .03 .1 .03])

nv = size(param.waveform,1);
slv = uicontrol('style','slider','Tag','v-slide', ...
    'Min', 1, 'Max', nv, 'Value', 1, 'SliderStep',[1/nv 1/nv], ...
    'unit','norm');
set(slv,'pos',[.25 .024 .5 .03])

edv = uicontrol('style','edit','Tag','v-edit', 'str','1','fontsize',14,'unit','norm');
set(edv,'pos',[.8 .03 .05 .03])


%% Callbacks
%  for unit-wavelength (l)
get_l_edit_handle  = 'hl=findobj(''tag'',''l-edit''); ';
update_l_variable  = 'l=str2num(get(hl,''str'')); ';

round_slider_value = 'set(gcbo,''value'',round(get(gcbo,''value''))); ';
update_edit_box    = 'set(hl,''str'',num2str(round(get(gcbo,''value'')))); ';
update_plot        = 'WM_plot7d_update;';

set(edl,'call',[get_l_edit_handle update_l_variable update_plot])
set(sll,'call',[round_slider_value get_l_edit_handle update_edit_box update_l_variable update_plot])

%  for MEAN PERIOD (p)
get_p_edit_handle  = 'hp=findobj(''tag'',''p-edit''); ';
update_p_variable  = 'p=str2num(get(hp,''str'')); ';

round_slider_value = 'set(gcbo,''value'',round(get(gcbo,''value''))); ';
update_edit_box    = 'set(hp,''str'',num2str(round(get(gcbo,''value'')))); ';
update_plot        = 'WM_plot7d_update;';

set(edp,'call',[get_p_edit_handle update_p_variable update_plot])
set(slp,'call',[round_slider_value get_p_edit_handle update_edit_box update_p_variable update_plot])

%  for temporal ORDER of jitter (o)
get_o_edit_handle  = 'ho=findobj(''tag'',''o-edit''); ';
update_o_variable  = 'o=str2num(get(ho,''str'')); ';

round_slider_value = 'set(gcbo,''value'',round(get(gcbo,''value''))); ';
update_edit_box    = 'set(ho,''str'',num2str(round(get(gcbo,''value'')))); ';
update_plot        = 'WM_plot7d_update;';

set(edo,'call',[get_o_edit_handle update_o_variable update_plot])
set(slo,'call',[round_slider_value get_o_edit_handle update_edit_box update_o_variable update_plot])

%  for WAVEFORMS (v)
get_v_edit_handle  = 'hv=findobj(''tag'',''v-edit''); ';
update_v_variable  = 'v=str2num(get(hv,''str'')); ';

round_slider_value = 'set(gcbo,''value'',round(get(gcbo,''value''))); ';
update_edit_box    = 'set(hv,''str'',num2str(round(get(gcbo,''value'')))); ';
update_plot        = 'WM_plot7d_update;';

set(edv,'call',[get_v_edit_handle update_v_variable update_plot])
set(slv,'call',[round_slider_value get_v_edit_handle update_edit_box update_v_variable update_plot])
