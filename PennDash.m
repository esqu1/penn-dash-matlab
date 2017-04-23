function PennDash
    f = figure('Visible','off','Position', [500 500 500 500]);
    %button1 = uicontrol('Style','PushButton','Units','normalized','Position',[.5 .5 .4 .4],'String','Dining Halls');
    
    title = uicontrol('Style','text','Units','normalized',...
                      'Position',[.1 .5 .8 .5],'String','Welcome to Penn Dash!',...
                      'FontSize',20);
    dining = uicontrol('Style','PushButton','Units','normalized',...
                       'Position',[.1 .7 .2 .1],'String','Dining Halls',...
                       'Callback',@Dining);
    movegui(f,'center');
    f.Visible = 'on';
    
    function t = timeConv(time)
        t = datestr(datenum(time,'HH:MM:SS'),16);
    end

    function Dining(source,eventData)
        title.Visible = 'off';
        dining.Visible = 'off';
        diningUpdate;
    end



    function diningUpdate
        dining = webread('http://api.pennlabs.org/dining/venues');
        venues = dining.document.venue;
        hours = '';
        names = cell(1,1);
        % Need to update this with necessary buttons
        for i=1:length(venues)
            v = venues{i};
            names{i} = v.name;
            try
                open = v.dateHours(1).meal.open;
                closed = v.dateHours(1).meal.close;
            catch
                continue
            end
            hours = sprintf([hours '\n%s'],[v.name ': ' timeConv(open) ' - ' timeConv(closed)]);
        end
        names
        h = uicontrol('Style','text','Units','normalized',...
                      'Position',[.5 .5 .3 .3],'String',hours);
        hall = uicontrol('Style','listbox','Units','normalized',...
                         'Position',[.1 .1 .3 .3],'String',names,'Callback',@updateHours,...
                         'UserData',struct('hours',h,'names',names));
                     
        function updateHours(source,eventData)
            try
                hour = venues{source.Value}.dateHours(1).meal;
            catch
                return
            end
            times = '';
            for i=1:length(hour)
                time = hour(i)
                try
                    open = time.open;
                    closed = time.close;
                catch
                    continue
                end
                times = sprintf([times '\n%s'],[time.type ': ' timeConv(open) ' - ' timeConv(closed)]);
            end
            h.String = times;
        end
    end
end