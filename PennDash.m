function PennDash
    RETURNTEXT = 'Return to Menu';
    f = figure('Visible','off','Position', [500 500 500 500]);
    title = uicontrol('Style','text','Units','normalized',...
                      'Position',[.1 .5 .8 .5],'String','Welcome to Penn Dash!',...
                      'FontSize',20);
    dining = uicontrol('Style','PushButton','Units','normalized',...
                       'Position',[.1 .7 .2 .1],'String','Dining Halls',...
                       'Callback',@Dining);
                   
    laundry = uicontrol('Style','PushButton','Units','normalized',...
                        'Position',[.4 .7 .2 .1], 'String','Laundry',...
                        'Callback',@Laundry);
                   
    central = {title dining laundry};
    movegui(f,'center');
    f.Visible = 'on';
    
    function t = timeConv(time)
        t = datestr(datenum(time,'HH:MM:SS'),16);
    end

    function Dining(source,eventData)
        dining.Enable = 'off';
        for i=1:length(central)
            central{i}.Visible = 'off';
        end
        d = webread('http://api.pennlabs.org/dining/venues');
        dining.Enable = 'on';
        venues = d.document.venue;
        hours = '';
        names = cell(1,1);
        % Need to update this with necessary buttons
        for i=1:length(venues)
            names{i} = venues{i}.name;
        end
        h = uicontrol('Style','text','Units','normalized',...
                      'Position',[.5 .5 .4 .4],'String',hours);
        hall = uicontrol('Style','listbox','Units','normalized',...
                         'Position',[.1 .1 .3 .3],'String',names,'Callback',@updateHours,...
                         'UserData',struct('hours',h,'names',names));
        returnToMenu = uicontrol('Style','pushButton', 'Units', 'normalized',...
                                 'Position', [.05 .8 .2 .1], 'String', RETURNTEXT,...
                                 'CallBack', @backtoMenu);
        f.Visible = 'on';
        function backtoMenu(source,eventData)
            h.Visible = 'off';
            hall.Visible = 'off';
            returnToMenu.Visible = 'off';
            for i=1:length(central)
                central{i}.Visible = 'on';
            end
        end
                     
        function updateHours(source,eventData)
            times = '';
            try
                hour = venues{source.Value}.dateHours(1).meal;
            catch
                h.String = 'Not available at this time.';
                return
            end
            for i=1:length(hour)
                time = hour(i);
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

    function Laundry(source,eventData)
        laundry.Enable = 'off';
        for i=1:length(central)
            central{i}.Visible = 'off';
        end
        d = webread('http://api.pennlabs.org/laundry/halls');
        laundry.Enable = 'on';
        halls = d.halls;
        for i=1:length(halls)
            n = strsplit(halls(i).name, '-');
            halls(i).building = n{1};
        end
        listOfBuildings = unique({halls.building});        
        l = uicontrol('Style','text','Units','normalized',...
                      'Position',[.5 .5 .4 .4],'String','');
        building = uicontrol('Style','listbox','Units','normalized',...
                 'Position',[.1 .1 .3 .3],'String',listOfBuildings,'Callback',@updateHours,...
                 'UserData',listOfBuildings);
        
        function updateLaundry(source,eventData)
            
        end    
    end


end