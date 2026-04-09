clear all;
load us_states.mat;
infile='ZhangLAB_GeochemData_SciAdv2023_Data_S1.csv';
data=readtable(infile);
lon_data=data.Longitude;
lat_data=data.Latitude;
value_data=data.LithosphericThickness_km_;
age_data=data.Age_Ma_;
% crange=[20,200];
% yrange_value=[0 300];
%%
load('vscontour_074_km_4.5_finedepth.mat');
flist=dir('outline_*.txt');
rKilometers = earthRadius('km');
min_area_plot=20000; %minimum area within contour to plot. unit is km^2.
min_contour_points=200;
% compute distance from the basalt samples to the Vs contour at 74 km depth
%get all points along the contour
figure; hold on;
linepoints=[];
for p =1:length(lineinfo)
    a_temp=areaint(lineinfo{p}.data(:,2),lineinfo{p}.data(:,1),rKilometers);

    if a_temp >= min_area_plot && size(lineinfo{p}.data,1) >= min_contour_points
    % if size(lineinfo{p}.data,1) >= min_contour_points
        linepoints=[linepoints;lineinfo{p}.data];
        plot(lineinfo{p}.data(:,1),lineinfo{p}.data(:,2),'k','linewidth',2,'Color','r');
    end
end
hold off;
%% 
master_pars;

% SCParea.lon=[-115,-107];
% SCParea.lat=[32,37];
SCParea.lon=[-115,-100];
SCParea.lat=[32,42];
age_max_sub=20;
% value_max=150; %this is to exclude extremely large values/thickness.
dage=1;
agelist=age_max_sub:-dage:0;

idx00 = age_data <= max(agelist) & lon_data >= SCParea.lon(1) & lon_data <= SCParea.lon(2) ... 
            & lat_data >= SCParea.lat(1) & lat_data <= SCParea.lat(2);

lon_data_SCP=lon_data(idx00);
lat_data_SCP=lat_data(idx00);
age_data_SCP=age_data(idx00);
value_data_SCP=value_data(idx00);
dist_SCP=nan(length(age_data_SCP),1);
%compute distance to craton for the subset of samples
parfor q=1:length(age_data_SCP)
    disp([num2str(q),'/',num2str(length(age_data_SCP))])
    dist_temp=nan(size(linepoints,1),1);
    for w=1:size(linepoints,1)
        [dist_temp2,~]=distance(lat_data_SCP(q),lon_data_SCP(q), ...
            linepoints(w,2),linepoints(w,1),wgs84Ellipsoid("km"));
        dist_temp(w)=dist_temp2;
    end
    dist_SCP(q)=min(dist_temp);
end

%%
%first group
% subarea.lon=[-114,-112.5];
% subarea.lat=[35.5,37];
%second group
% subarea.lon=[-113,-111];
% subarea.lat=[34.5, 35.5];
%third group
% subarea.lon=[-110.5,-109];
% subarea.lat=[33.5, 34.5];
%4 group
% subarea.lon=[-113,-111];
% subarea.lat=[33.5, 35.5];
dlon=0.5; dlat=dlon; %0.5;
lon=SCParea.lon(1):dlon:SCParea.lon(2);
lat=SCParea.lat(1):dlat:SCParea.lat(2);

%
dist_range=[0,1000];
figflag_age=0;
predict_r2_min=0.85;
minslope=0.1;
out_results={};
% plot all samples.
for itop=1:length(lon)-1
    for jtop=1:length(lat)-1
        subarea.lon=[lon(itop),lon(itop + 1)];
        subarea.lat=[lat(jtop),lat(jtop + 1)];
        idx0 = lon_data_SCP >= subarea.lon(1) & lon_data_SCP < subarea.lon(2) ... 
            & lat_data_SCP >= subarea.lat(1) & lat_data_SCP < subarea.lat(2);
        if sum(idx0)<2
            continue;
        end
        lon_data_sub=lon_data_SCP(idx0);
        lat_data_sub=lat_data_SCP(idx0);
        age_data_sub=age_data_SCP(idx0);
        value_data_sub=value_data_SCP(idx0);
        dist_sub=dist_SCP(idx0);
        
        % get LAB for each age interval within a distance range from the craton
        
        stat_mean=nan(length(agelist)-1,1);
        stat_min=nan(length(agelist)-1,1);
        stat_median=nan(length(agelist)-1,1);
        stat_std=nan(length(agelist)-1,1);
        dist_mean=nan(length(agelist)-1,1);
        dist_min=nan(length(agelist)-1,1);
         
        videoflag=0;
        if videoflag
            figflag_age=1;
            nframe=12; %number of repeating frames for each age interval.
            v=VideoWriter("Basalt_LAB_SCP.avi");
            open(v);
        end
        if figflag_age
            figure('Position',[200,400,850,300]);
        end
        for i=1:length(agelist)-1
            age_max=agelist(i);
            age_min=agelist(i+1);
            idx3=age_data_sub <= age_max & age_data_sub >= age_min & ...
                dist_sub >= dist_range(1) & dist_sub <= dist_range(2);
            if sum(idx3)>0
                stat_mean(i)=mean(value_data_sub(idx3));
                [stat_min(i),min_idx]=min(value_data_sub(idx3));
                stat_median(i)=median(value_data_sub(idx3));
                stat_std(i)=std(value_data_sub(idx3));
                dist_mean(i)=mean(dist_sub(idx3));
                nonzero_idx=find(idx3>0);
                dist_min(i)=dist_sub(nonzero_idx(min_idx));
                %
                if figflag_age
                    clf;
                    subplot(1,2,1); hold on;
                    axis([maparea.lon(1) maparea.lon(2) maparea.lat(1) maparea.lat(2)]);
                    daspect([1 cosd(mean(maparea.lat)) 1]);
                        
                    for sb=1:length(state)
                        plot(state(sb).polygon(:,1), state(sb).polygon(:,2),'color',0.6+[.0 .0 .0],'LineWidth',0.5);
                    end
                    %plot major structural domain outlines
                    for k =1:length(flist)
                        infile=flist(k).name;
                        outline=load(infile);
                        
                        plot(outline(:,1),outline(:,2),'k-','linewidth',1.);%,'color',0.*[1 1 1]);
                    end
                    %plot velocity contour
                    
                    for p =1:length(lineinfo)
                        a_temp=areaint(lineinfo{p}.data(:,2),lineinfo{p}.data(:,1),rKilometers);
                        if a_temp >= min_area_plot
                            plot(lineinfo{p}.data(:,1),lineinfo{p}.data(:,2),'k','linewidth',2,'Color','r');
                        end
                    end
                    scatter(lon_data_sub(idx3),lat_data_sub(idx3),60,value_data_sub(idx3),'filled', ...
                        'MarkerEdgeColor',[0,0,0],'MarkerFaceAlpha',1);
                    title(['a. ',num2str(age_max),'-',num2str(age_min),' Ma, min: ', ...
                        num2str(min(value_data_sub(idx3)),3),', mean: ',num2str(mean(value_data_sub(idx3)),3)],...
                        'FontSize',14)
            
                    hold off;
                    colormap(flip(colormap(parula(20))));
                    colorbar;
                    set(gca,'CLim',crange,'FontSize',14,'TitleHorizontalAlignment','left','TickDir','out')
                    xlim(maparea.lon);
                    ylim(maparea.lat)
                    axis on;
                    box on;
                    
                    subplot(1,2,2); hold on;
                    scatter(age_data_sub(idx3),value_data_sub(idx3),40,'b','filled')
                    ylim(yrange_value);
                    % xlim([0, age_min_sub]);
                    axis on;
                    box on;
                    
                    title(['b. ',num2str(age_max),'-',num2str(age_min),' Ma, min: ', ...
                        num2str(min(value_data_sub(idx3)),3),', mean: ',num2str(mean(value_data_sub(idx3)),3)],...
                        'FontSize',14)
                    xlabel('Age (Ma)')
                    ylabel('Lithospheric thickness (km)')
                    set(gca,'FontSize',14,'TitleHorizontalAlignment','left','TickDir','out')
                
                    saveas(gca,strcat('lab_near_craton_',num2str(age_max),'-',num2str(age_min),'.png'))
                    if videoflag
                        frame=getframe(gcf);
                        for k=1:nframe
                            writeVideo(v,frame);
                        end
                    end
                end
            end
        end
        if videoflag
            close(v)
        end
        if figflag_age
            close;
        end
        %
        yrange=[10 120];
        plotx_temp=agelist(1:end-1)-0.5*dage;
        idx_data=~isnan(stat_min);
        plotx=plotx_temp(idx_data);
        ploty=stat_min(idx_data);
        if length(ploty)<2
            continue;
        end
        pfit=polyfit(plotx,ploty,1);
        ploty_pred=polyval(pfit,plotx);
        SStot = sum((ploty-mean(ploty)).^2);                    % Total Sum-Of-Squares
        SSres = sum((ploty-ploty_pred').^2);                       % Residual Sum-Of-Squares
        Rsq = 1-SSres/SStot;    
        if Rsq < predict_r2_min || pfit(1) < minslope
            continue;
        end
        
        idx2=age_data_sub <= max(agelist) & age_data_sub >= min(agelist) & ...
                dist_sub >= dist_range(1) & dist_sub <= dist_range(2);
        if sum(idx2)<1
            continue;
        end
    
        %store data in struct
        out_grid.data=[lon_data_sub(idx2),lat_data_sub(idx2),value_data_sub(idx2),dist_sub(idx2)];
        out_grid.min=[plotx',ploty,dist_min(idx_data)];
        out_grid.location=[mean(subarea.lon),mean(subarea.lat)];
        out_grid.slope=pfit(1);

        out_results{end+1}=out_grid;
        figure('Position',[600,400,850,350]);
        
        crange=[20,160];
        subplot(1,2,1); hold on;
        axis([maparea.lon(1) maparea.lon(2) maparea.lat(1) maparea.lat(2)]);
        daspect([1 cosd(mean(maparea.lat)) 1]);
            
        for sb=1:length(state)
            plot(state(sb).polygon(:,1), state(sb).polygon(:,2),'color',0.6+[.0 .0 .0],'LineWidth',0.5);
        end
        %plot major structural domain outlines
        for k =1:length(flist)
            infile=flist(k).name;
            outline=load(infile);
            
            plot(outline(:,1),outline(:,2),'k-','linewidth',1.);%,'color',0.*[1 1 1]);
        end
        %plot velocity contour
        
        for p =1:length(lineinfo)
            a_temp=areaint(lineinfo{p}.data(:,2),lineinfo{p}.data(:,1),rKilometers);
            if a_temp >= min_area_plot
                plot(lineinfo{p}.data(:,1),lineinfo{p}.data(:,2),'k','linewidth',2,'Color','r');
            end
        end
        scatter(lon_data_sub(idx2),lat_data_sub(idx2),50,value_data_sub(idx2),'filled', ...
            'MarkerEdgeColor',[0,0,0],'MarkerFaceAlpha',1);
        title('a. Samples near S. Colorado Plateau',...
            'FontSize',12)
        
        hold off;
        colormap(flip(colormap(cool(20))));
        hcbar=colorbar;
        hcbar.Label.String='Lithospheric thickness (km)';
        hcbar.Label.FontSize=12;
        hcbar.TickDirection='out';
        hcbar.Location='eastoutside';
        hcbar.Ticks=crange(1):20:crange(2);
        set(gca,'CLim',crange,'FontSize',14,'TitleHorizontalAlignment','center','TickDir','out')
        xlim(maparea.lon);
        ylim(maparea.lat)
        axis on;
        box on;
        % set(gcf,'renderer','Painters','PaperPositionMode','auto'); 
        % saveas(gca,strcat('WNACraton_basalt_LAB_SCP_samplelocations_',num2str(itop),'_',num2str(jtop),'.png'))
        % print -dpdf -r300 -vector 'WNACraton_basalt_LAB_SCP_samplelocations.pdf';
        %

        subplot(1,2,2); hold on;
        % h1=errorbar(plotx,ploty,ploterr,'ko','LineWidth',1., ...
        %     'DisplayName','1 std');
        % plot(age_data_sub(idx2),value_data_sub(idx2),'k.')
        plot(plotx,ploty,'b-','LineWidth',1.5)
        h1=scatter(plotx,ploty,50,dist_min(idx_data),'filled','MarkerEdgeColor','k','DisplayName','Minimum thickness');
        
        h2=plot(plotx,ploty_pred,'r--','LineWidth',2,...
            'DisplayName','Linear fit (mininum)');
        
        %
        % ploty2=stat_mean;
        % ploterr=stat_std;
        % % h3=errorbar(plotx,ploty2,ploterr,'k^','LineWidth',1., ...
        % %     'DisplayName','1 std');
        % plot(plotx,ploty2,'k-','LineWidth',1.5)
        % h4=scatter(plotx,ploty2,50,dist_mean,'filled','MarkerEdgeColor','k',...
        %     'DisplayName','Mean thickness','Marker','^');
        % pfit2=polyfit(plotx,ploty2,1);
        % 
        % h5=plot(plotx,polyval(pfit2,plotx),'m:','LineWidth',2,...
        %     'DisplayName','Linear fit (mean)');
        
        xlim([min(agelist),max(agelist)]);
        % ylim(yrange);
        xlabel('Age (Ma)')
        ylabel('Lithospheric thickness (km)')
        
        text(3,16,sprintf('$$y = %5.2f x %+6.2f $$',pfit(1),pfit(2)),'Interpreter', 'latex', ...
            'fontsize', 14,'Color','r');
        % text(3,100,sprintf('$$y = %5.2f x %+6.2f $$',pfit2(1),pfit2(2)),'Interpreter', 'latex', ...
        %     'fontsize', 14,'Color','m');
        % legend([h1,h2],'Location','best','FontSize',10);
        title(['b. Basalts near S. CP, R^2: ',num2str(Rsq)],'FontSize',14);
        colormap(parula(20));
        hcbar=colorbar;
        hcbar.Label.String='Distance to modern craton (km)';
        hcbar.Label.FontSize=12;
        hcbar.TickDirection='out';
        grid on;
        hold off;
        axis on;
        box on;
        set(gca,'FontSize',12,'CLim',dist_range, ...
            'XTick',min(agelist):2:max(agelist),'TickDir','out','TitleHorizontalAlignment','center')
        %,'YTick',yrange(1):10:yrange(2)
        orient('landscape')
        set(gcf,'renderer','Painters','PaperPositionMode','auto'); 
        saveas(gca,strcat('WNACraton_basalt_LAB_SCP_pattern_dlon',num2str(dlon),'_dlat',num2str(dlat),'_',...
            num2str(itop),'_',num2str(jtop),'.png'))
        % print -dpdf -r300 -vector 'WNACraton_basalt_LAB_SCP.pdf';

        close all;
    end
end
%%
colorlist=turbo(length(out_results));

% crange=[20,160];

figure('Position',[600,400,300,320]); hold on;
axis([maparea.lon(1) maparea.lon(2) maparea.lat(1) maparea.lat(2)]);
daspect([1 cosd(mean(maparea.lat)) 1]);
    
for sb=1:length(state)
    plot(state(sb).polygon(:,1), state(sb).polygon(:,2),'color',0.4+[.0 .0 .0],'LineWidth',0.25);
end
%plot major structural domain outlines
for k =1:length(flist)
    infile=flist(k).name;
    outline=load(infile);
    
    plot(outline(:,1),outline(:,2),'k-','linewidth',1.);%,'color',0.*[1 1 1]);
end
%plot velocity contour

for p =1:length(lineinfo)
    a_temp=areaint(lineinfo{p}.data(:,2),lineinfo{p}.data(:,1),rKilometers);
    if a_temp >= min_area_plot && size(lineinfo{p}.data,1) >= min_contour_points
        plot(lineinfo{p}.data(:,1),lineinfo{p}.data(:,2),'k','linewidth',1,'Color','m');
    end
end
% scatter(lon_data_SCP,lat_data_SCP,60,'k','MarkerEdgeColor',0.4+[0,0,0]);
phandle=[];
for i =1:length(out_results)
    h1=scatter(out_results{i}.location(1),out_results{i}.location(2),180,'k','filled', ...
        'MarkerEdgeColor','none','MarkerFaceAlpha',1,'markerfacecolor',colorlist(i,:),'DisplayName',[num2str(i)]);
    text(out_results{i}.location(1),out_results{i}.location(2),num2str(i),'FontSize',9,'Color',0.4*[1,1,1],...
        'HorizontalAlignment','center','VerticalAlignment','middle')
    % h1=scatter(out_results{i}.data(:,1),out_results{i}.data(:,2),60,out_results{i}.data(:,3),'filled', ...
    %     'MarkerEdgeColor',[0,0,0],'MarkerFaceAlpha',1,'markerfacecolor',colorlist(i,:),'DisplayName',[num2str(i)]);
    % if i > 9
    %     h1.SizeData=80;
    %     h1.MarkerEdgeColor='k';
    %     h1.Marker='d';
    % end
    phandle(end+1)=h1;
end
% title('a. Samples','FontSize',12)
% legend(phandle,'Location','eastoutside','FontSize',10,'NumColumns',1);
hold off;
% colormap(flip(colormap(cool(20))));
% hcbar=colorbar;
% hcbar.Label.String='Lithospheric thickness (km)';
% hcbar.Label.FontSize=12;
% hcbar.TickDirection='out';
% hcbar.Location='eastoutside';
% hcbar.Ticks=crange(1):20:crange(2);
% set(gca,'CLim',crange)
set(gca,'FontSize',14,'TitleHorizontalAlignment','center','TickDir','out')
xlim(maparea.lon);
ylim(maparea.lat)
axis on;
box on;
set(gcf,'renderer','Painters','PaperPositionMode','auto'); 
% saveas(gca,strcat('WNACraton_basalt_LAB_SCP_pattern_dlon',num2str(dlon),'_dlat',num2str(dlat),'_',...
%     num2str(itop),'_',num2str(jtop),'.png'))
print -dpdf -r300 -vector 'WNACraton_basalt_LAB_patterns_locations.pdf';

%%
xrange=[min(agelist),age_max_sub]; %max(agelist)
yrange=[10,250];

figure('Position',[600,400,420,300]); hold on;
phandle=[];
for i =1:length(out_results)
    plotx=out_results{i}.min(:,1);
    ploty=out_results{i}.min(:,2);
    h2=plot(plotx,ploty,'o-','LineWidth',1.5,'Color',colorlist(i,:),'MarkerEdgeColor','k',...
        'markerfacecolor',colorlist(i,:),'DisplayName',[num2str(i)]);
    % h3=scatter(plotx,ploty,50,out_results{i}.min(:,3),'filled','MarkerEdgeColor','k',...
    %     'markerfacecolor',colorlist(i,:),'DisplayName',[num2str(i)]);
    % if i > 9
    %     h2.LineStyle='--';
    %     h2.MarkerSize=7;
    %     h2.MarkerEdgeColor='k';
    %     h2.Marker='d';
    % end
    phandle(end+1)=h2;
end
xlim(xrange);
ylim(yrange);
xlabel('Age (Ma)')
ylabel('Depth (km)')

% text(3,16,sprintf('$$y = %5.2f x %+6.2f $$',pfit(1),pfit(2)),'Interpreter', 'latex', ...
%     'fontsize', 14,'Color','r');
% text(3,100,sprintf('$$y = %5.2f x %+6.2f $$',pfit2(1),pfit2(2)),'Interpreter', 'latex', ...
%     'fontsize', 14,'Color','m');
legend(phandle,'Location','southoutside','FontSize',10,'NumColumns',6);

% colormap(parula(20));
% hcbar=colorbar;
% hcbar.Label.String='Distance to modern craton (km)';
% hcbar.Label.FontSize=12;
% hcbar.TickDirection='out';
% hcbar.Location='southoutside';

grid on;
hold off;
axis on;
box on;
set(gca,'FontSize',12,'CLim',dist_range, 'YScale','log','YTick',0:50:yrange(2),...
    'XTick',min(agelist):2:max(agelist),'TickDir','out','TitleHorizontalAlignment','center')
title('Minimum thickness','FontSize',14);
%,'YTick',yrange(1):10:yrange(2)
% orient('landscape')
set(gcf,'renderer','Painters','PaperPositionMode','auto'); 
% saveas(gca,strcat('WNACraton_basalt_LAB_SCP_pattern_dlon',num2str(dlon),'_dlat',num2str(dlat),'_',...
%     num2str(itop),'_',num2str(jtop),'.png'))
print -dpdf -r300 -vector 'WNACraton_basalt_LAB_patterns.pdf';


%%
xrange=[min(agelist),24]; %max(agelist)
% yrange=[0,50];

figure('Position',[600,400,420,250]); hold on;
phandle=[];
for i =1:length(out_results)
    ploty=out_results{i}.slope;
    stem(i,ploty,'o-','LineWidth',1.,'Color',colorlist(i,:),'MarkerEdgeColor','k',...
        'markerfacecolor',colorlist(i,:),'MarkerSize',9,'DisplayName',[num2str(i)]);
    % h3=scatter(plotx,ploty,50,out_results{i}.min(:,3),'filled','MarkerEdgeColor','k',...
    %     'markerfacecolor',colorlist(i,:),'DisplayName',[num2str(i)]);
    % if i > 9
    %     h2.LineStyle='--';
    %     h2.MarkerSize=7;
    %     h2.MarkerEdgeColor='k';
    %     h2.Marker='d';
    % end
    % phandle(end+1)=h2;
end
xlim([0.5,length(out_results)+0.5]);
% ylim(yrange);
% xlabel('Age (Ma)')
ylabel('Slope')

% text(3,16,sprintf('$$y = %5.2f x %+6.2f $$',pfit(1),pfit(2)),'Interpreter', 'latex', ...
%     'fontsize', 14,'Color','r');
% text(3,100,sprintf('$$y = %5.2f x %+6.2f $$',pfit2(1),pfit2(2)),'Interpreter', 'latex', ...
%     'fontsize', 14,'Color','m');
% legend(phandle,'Location','southoutside','FontSize',9,'NumColumns',6);

% colormap(parula(20));
% hcbar=colorbar;
% hcbar.Label.String='Distance to modern craton (km)';
% hcbar.Label.FontSize=12;
% hcbar.TickDirection='out';
% hcbar.Location='southoutside';

grid on;
hold off;
axis on;
box on;
set(gca,'FontSize',12,'CLim',dist_range, 'yscale','log',...
    'XTick',1:length(out_results),'TickDir','out','TitleHorizontalAlignment','center')
title('Slope','FontSize',12);
%,'YTick',yrange(1):10:yrange(2)
% orient('landscape')
set(gcf,'renderer','Painters','PaperPositionMode','auto'); 

print -dpdf -r300 -vector 'WNACraton_basalt_LAB_patterns_slope.pdf';