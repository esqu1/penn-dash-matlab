function PennDash
    %% Global Variables
    RETURNTEXT = 'Return to Menu';
    RETURNPOSITION = [.75 .87 .2 .1];
    weboptions('Timeout',20); % API's are slow so we allow for some time
    
    %% Initial API Calls
    weather = webread('http://api.pennlabs.org/weather'); % Weather
    d = webread('http://api.pennlabs.org/dining/venues'); % Dining
    d2 = webread('http://api.pennlabs.org/laundry/halls'); % Laundry
    spaces = webread('http://api.pennlabs.org/studyspaces/'); % Study Spaces
    SUBTITLE = sprintf('It is now %s, and it is currently %s.',datestr(now,'mmmm dd, yyyy HH:MM:SS PM'),[num2str(weather.weather_data.main.temp) '°F']);
     
    %% Making the GUI
    f = figure('Visible','off','Position', [500 500 800 700]);
    title = uicontrol('Style','text','Units','normalized',...
                      'Position',[.1 .7 .8 .25],'String','Welcome to Penn Dash!',...
                      'FontSize',20);
    subtitle = uicontrol('Style','text','Units','normalized',...
                         'Position', [.1 .57 .8 .3],'String',SUBTITLE);
    dining = uicontrol('Style','PushButton','Units','normalized',...
                       'Position',[.1 .5 .3 .3],'String','Dining Halls',...
                       'Callback',@Dining, 'FontSize',18);
                   
    laundry = uicontrol('Style','PushButton','Units','normalized',...
                        'Position',[.6 .5 .3 .3], 'String','Laundry',...
                        'Callback',@Laundry, 'FontSize',18);
                    
    buildings = uicontrol('Style', 'PushButton','Units', 'normalized',...
                          'Position', [.1 .1 .3 .3], 'String', 'Buildings',...
                          'Callback',@Buildings,'FontSize',18);
                      
    studyspaces = uicontrol('Style','PushButton','Units','normalized',...
                            'Position', [.6 .1 .3 .3], 'String', 'Studyspaces',...
                            'Callback', @StudySpaces, 'FontSize',18);
                            
    central = {title subtitle dining laundry buildings studyspaces};
    movegui(f,'center');
    f.Visible = 'on';
    set(gcf, 'Resize','off'); % turn off window resizing
    
    %% Helper Functions
    function t = timeConv(time)
        % Converts a string containing the current time in HH:MM:SS format
        % to a MMM DD, YYYY HH:MM:SS AM/PM format.
        t = datestr(datenum(time,'HH:MM:SS'),16);
    end

    function hour = time2hour(t)
        % Converts a 'HH:MM:DDPM' date format to an integer from 1 to
        % 24. This is for the array of buttons representing the
        % available time slots for rooms.
        s = strsplit(t,':');
        latter = s{2};
        hour = 2*mod(str2num(s{1}),12) + 1;
        if strcmp(latter((end-1):end),'PM')
            hour = hour + 24;
        end
        if str2num(latter(1:2)) == 30
            hour = hour + 1;
        end
    end

    %% Main Dining Callback
    function Dining(source,eventData)
        for i=1:length(central)
            central{i}.Enable = 'off';
            central{i}.Visible = 'off';
        end
        
        for i=1:length(central)
            central{i}.Enable = 'on';
        end
        venues = d.document.venue;
        hours = '';
        names = cell(1,1);
        for i=1:length(venues)
            names{i} = venues{i}.name;
        end
        
        % Creating the layout
        h = uicontrol('Style','text','Units','normalized',...
                      'Position',[.5 .3 .4 .4],'String',hours);
        hall = uicontrol('Style','listbox','Units','normalized',...
                         'Position',[.05 .1 .3 .3],'String',names,'Callback',@updateHours);
        returnToMenu = uicontrol('Style','pushButton', 'Units', 'normalized',...
                                 'Position', RETURNPOSITION, 'String', RETURNTEXT,...
                                 'CallBack', @backtoMenu);
        text = uicontrol('Style','text','Units','normalized',....
                         'Position',[.05 .4 .3 .1],'String',...
                         'Select your dining hall here:','FontSize',16);
        text2 = uicontrol('Style','text','Units','normalized',....
                         'Position',[.05 .5 .3 .2],'String',...
                         'This widget allows you to view where and where to get food.','FontSize',14);
        top = uicontrol('Style','text','Units','normalized',...
                      'Position',[.25 .7 .5 .25],'String','Dining Hall Open Hours',...
                      'FontSize',20);
        hallName = uicontrol('Style','text','Units','normalized',...
                             'Position',[.45 .7 .5 .05],'String','','FontSize',16);
        
        function backtoMenu(source,eventData)
            % Callback for the "Return to Menu" button.
            delete(h); delete(hall); delete(returnToMenu);
            delete(text); delete(text2); delete(top);
            delete(hallName);
            for i=1:length(central)
                central{i}.Visible = 'on';
            end
        end
                     
        function updateHours(source,eventData)
            % Updates the uicontrol text with the hours as the user selects
            % a dining hall.
            times = '';            
            hallName.String = [venues{source.Value}.name ':'];
            try % hours might be nonexistent
                hour = venues{source.Value}.dateHours(1).meal;
            catch
                h.String = 'Not available at this time.';
                return
            end
            for i=1:length(hour) % Gathers the list of hours of the hall.
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
            hallName.String = [venues{source.Value}.name ':'];
        end
    end

    %% Main Laundry Callback
    function Laundry(source,eventData)
        for i=1:length(central)
            central{i}.Enable = 'off';
            central{i}.Visible = 'off';
        end
        
        for i=1:length(central)
            central{i}.Enable = 'on';
        end
        
        % Creating the layout
        halls = d2.halls;
        building = uicontrol('Style','listbox','Units','normalized',...
                    'Position',[.05 .1 .3 .3],'String',{halls.name},...
                    'Callback',@updateLaundry,'UserData',halls);
        returnToMenu = uicontrol('Style','pushButton', 'Units', 'normalized',...
                    'Position', RETURNPOSITION, 'String', RETURNTEXT,...
                    'CallBack', @backtoMenu);
        l = uicontrol('Style','text','Units','normalized',...
                    'Position',[.5 .1 .4 .3],'String','','FontSize',14);
        top = uicontrol('Style','text','Units','normalized',...
                      'Position',[.25 .7 .5 .25],'String','Laundry Machines',...
                      'FontSize',20);
        graph = uipanel('Title','Main','Position',[.05 .5 .9 .3]);
        text = uicontrol('Style','text','Units','normalized',....
                         'Position',[.05 .4 .3 .08],'String',...
                         'Select your laundry hall here:','FontSize',16);
        text2 = uicontrol('Style','text','Units','normalized',....
                         'Position',[.05 .8 .9 .05],'String',...
                         'This widget tells you what laundry machines are open, and their usages.','FontSize',14);
        a = axes(graph); % Graph for displaying the usage intensities
        
        function backtoMenu(source,~)
            % Callback for the "Return to Menu" button.
            delete(l); delete(building); delete(returnToMenu); delete(top);
            graph.Visible = 'off'; delete(text); delete(text2);
            for i=1:length(central)
                central{i}.Visible = 'on';
            end
        end
        
        function updateLaundry(source,~)
            % Updates the laundry machine percentages as well as the graph
            % displaying the usage intensities.
            halls = source.UserData;
            string = '';
            for i=1:length(halls)
                h = halls(i);
                if strcmp(h.name,halls(source.Value).name) % selected hall
                    string = sprintf([string '\n%s\nAvailable Washers: %d/%d\nAvailable Dryers: %d/%d'],...
                        h.name, ...
                        h.washers_available,... 
                        h.washers_in_use + h.washers_available,...
                        h.dryers_available, ...
                        h.dryers_in_use + h.dryers_available);
                    usages = webread(['http://api.pennlabs.org/laundry/usage/' num2str(source.Value)]);
                    days = fieldnames(usages.days);
                    for i=1:length(days) % Compiles the usage intensities
                        hours = zeros(24);
                        for j=1:length(usages.days.(days{i}))
                            degree = usages.days.(days{i}){j};
                            if strcmp(degree,'Low') | strcmp(degree,'No Data')
                                hours(j) = 0;
                            elseif strcmp(degree, 'Medium')
                                hours(j) = 1;
                            elseif strcmp(degree, 'High')
                                hours(j) = 2;
                            elseif strcmp(degree, 'Very High')
                                hours(j) = 3;
                            end
                        end
                        usages.days.(days{i}) = hours;
                    end
                    
                    % Graphing
                    cla;
                    [V, dayName] = weekday(now,'long');
                    bar(1:24,usages.days.(dayName),25);
                    ylim([0 4]);
                    set(gca,'xtick', 0:24);
                    xlabel('Hour of Day');
                    ylabel('Usage Intensity');
                    legend(dayName);
                    break;
                end
            end
            l.String = string;
        end
    end

    %% Main Buildings Callback
    function Buildings(source, ~)
        for i=1:length(central)
            central{i}.Enable = 'off';
            central{i}.Visible = 'off';
        end
        for i=1:length(central)
            central{i}.Enable = 'on';
        end
        
        % Creating the layout
        top = uicontrol('Style','text','Units','normalized',...
              'Position',[.25 .8 .5 .15],'String','Building Search',...
              'FontSize',20);
        returnToMenu = uicontrol('Style','pushButton', 'Units', 'normalized',...
                    'Position', RETURNPOSITION, 'String', RETURNTEXT,...
                    'CallBack', @backtoMenu);        
        text2 = uicontrol('Style','text','Units','normalized',....
                         'Position',[.05 .5 .3 .08],'String',...
                         'Enter a search term:','FontSize',16);
        text3 = uicontrol('Style','text','Units','normalized',....
                         'Position',[.05 .6 .3 .2],'String',...
                         'This widget gives information on all of the buildings at Penn.','FontSize',14);

        searchbar = uicontrol('Style','edit','Units','normalized',...
                              'Position',[.05 .5 .3 .04],'CallBack',@fetchBuilding);
        results = uicontrol('Style','listbox','Units','normalized',...
                             'Position',[.05 .1 .3 .3],'CallBack', @showResult);
        
        textResult = uicontrol('Style','text','Units','normalized',...
                               'Position',[.35 .77 .65 .08],'FontSize',16);
        descrip = uicontrol('Style','text','Units','normalized',...
                               'Position',[.39 0 .57 .45],'FontSize',7);        
        resultData = {}; namesOfBuildings = {}; im = [];

        text = uicontrol('Style','text','Units','normalized',....
                         'Position',[.05 .4 .3 .08],'String',...
                         'and select a building:','FontSize',16);
                         
        function backtoMenu(source,eventData)
            % Callback for the "Return to Menu" button.
            delete(returnToMenu); delete(searchbar); delete(results);
            delete(textResult); delete(descrip); im.Visible = 'off';
            delete(text); delete(text2); delete(text3); delete(top);
            for i=1:length(central)
                central{i}.Visible = 'on';
            end
        end

        function fetchBuilding(source,~)
            % Fetches the search results from a search query from the user.
            results.Value = 1;
            resultData = webread(['http://api.pennlabs.org/buildings/search?q=' source.String]);
            try
                namesOfBuildings = {resultData.result_data.title};
                searchbar.BackgroundColor = 'white';
            catch
                searchbar.BackgroundColor = 'red';
                results.String = [];
                return;
            end
            results.String = namesOfBuildings;
        end
        
        function showResult(source,~)
            % Shows the result of the selected building name.
            b = resultData.result_data(source.Value);
            textResult.String = b.title;
            axes('Units','normalized','Position',[.45 .47 .45 .3]);
            im.Visible = 'off';
            im = image(imread(b.campus_item_images(1).image_url));
            im.Visible = 'on';
            axis off;
            if strcmp(b.address,'')
                b.address = 'N/A';
            end
            descrip.String = sprintf('%s\nAddress: %s', b.description, b.address);
        end
    end

    %% Main Study Spaces Callback
    function StudySpaces(source,~)
        for i=1:length(central)
            central{i}.Enable = 'off';
            central{i}.Visible = 'off';
        end
        for i=1:length(central)
            central{i}.Enable = 'on';
        end
        names = {spaces.studyspaces.name};        
        dates = datetime('now') + days(0:7);
        possibleDates = cell(1,8);
        for i=1:length(dates)
           possibleDates{i} = datestr(dates(i),29);
        end
        
        % Creating the layout   
        top = uicontrol('Style','text','Units','normalized',...
              'Position',[.25 .8 .5 .15],'String','Studyspace Search',...
              'FontSize',20);
        returnToMenu = uicontrol('Style','pushButton', 'Units', 'normalized',...
                    'Position', RETURNPOSITION, 'String', RETURNTEXT,...
                    'CallBack', @backtoMenu);
        results = uicontrol('Style','listbox','Units','normalized',...
                             'Position',[.05 .4 .25 .3],'CallBack', @showRooms,...
                             'String',names, 'UserData',1);
        dates = uicontrol('Style','listbox','Units','normalized',...
                          'Position',[.375 .4 .25 .3],'CallBack', @showRooms,...
                          'String',possibleDates, 'UserData',2);
        r = uicontrol('Style','listbox','Units','normalized',...
                          'Position',[.7 .4 .25 .3],'CallBack', @showResult);
        text2 = uicontrol('Style','text','Units','normalized',....
                         'Position',[.05 .8 .9 .05],'String',...
                         'This widget tells you what group study rooms are open.','FontSize',14);
        
        text3 = uicontrol('Style','text','Units','normalized',...
                           'Position',[.07 .7 .2 .1], 'String',...
                           'Select your venue:','FontSize',14);                       
        text4 = uicontrol('Style','text','Units','normalized',...
                           'Position',[.4 .7 .2 .1], 'String',...
                           'Select a date:','FontSize',14);                       
        text5 = uicontrol('Style','text','Units','normalized',...
                           'Position',[.7 .7 .2 .1], 'String',...
                           '...and select a room:','FontSize',14);
                       
        text6 = uicontrol('Style','text','Units','normalized',...
                           'Position',[.4 .1 .2 .1], 'String',...
                           'View available time slots above.','FontSize',14);
        currIDValue = 1; currDateValue = 1;
        
        slots = {};
                  
        availabilityButtons = gobjects(1,48); % buttons with availabilities
        labels = gobjects(1,12);
        labels(1) = uicontrol('Style','text','Units','normalized',...
                          'Position',[.073+0.03 .305 .05 .05],'String',...
                          '12');
        for j=2:size(labels,2)
            labels(j) = uicontrol('Style','text','Units','normalized',...
                          'Position',[.072+0.03+0.06*(j-1) .305 .05 .05],'String',...
                          num2str(j-1));
        end
        
        AM = uicontrol('Style','text','Units','normalized',...
                          'Position',[.089 .275 .05 .05],'String',...
                          'AM');
                      
        PM = uicontrol('Style','text','Units','normalized',...
                          'Position',[.089 .225 .05 .05],'String',...
                          'PM');
        for j=1:size(availabilityButtons,2)/2
            availabilityButtons(j) = uicontrol('Style','PushButton','Units','normalized',...
                                  'Position',[.1+j*0.03 .3 0.03 0.03]);
            
        end
        
        for j=(size(availabilityButtons,2)/2+1):size(availabilityButtons,2)
            availabilityButtons(j) = uicontrol('Style','PushButton','Units','normalized',...
                         'Position',...
                         [.1+(j-size(availabilityButtons,2)/2)*0.03 .25 0.03 0.03]);
        end
        

        
        function backtoMenu(source,~)
            % Callback for the "Return to Menu" button.
            delete(returnToMenu); delete(results); delete(dates); delete(top);
            delete(availabilityButtons); delete(labels); delete(AM); delete(PM);
            delete(r); delete(text2); delete(text3); delete(text4);
            delete(text5); delete(text6);
            for i=1:length(central)
                central{i}.Visible = 'on';
            end
        end
        
        function showRooms(source,~)
            % Callback for showing the available rooms for a given venue
            % and date.
            if source.UserData == 1 
                currIDValue = source.Value;
                r.Value = 1;
            else
                currDateValue = source.Value;
                r.Value = 1;
            end
            ids = {spaces.studyspaces.id};
            id = ids{currIDValue};
            avail = webread(['http://api.pennlabs.org/studyspaces/' possibleDates{currDateValue} '?id=' num2str(id)]);
            try
                rooms = unique({avail.studyspaces.room_name});
            catch
                disp('No rooms found!');
                return;
            end           
            slots = avail.studyspaces;
            r.String = rooms;
        end
        
        function showResult(source,~)
            % Callback for showing the available time slots for a
            % particular room in a venue.
            for i=1:size(availabilityButtons,2)
                availabilityButtons(i).Value = 0;
            end
            for i=1:length(slots) % Checks which buttons to make green.
                button = time2hour(slots(i).start_time);
                if strcmp(slots(i).room_name, r.String{source.Value})
                    availabilityButtons(button).BackgroundColor = 'green';
                    availabilityButtons(button).Value = 1;
                end
            end
            for i=1:size(availabilityButtons,2) % Make the rest red.
                if availabilityButtons(i).Value ~= 1
                    availabilityButtons(i).BackgroundColor = 'red';
                end
            end
        end
    end
end