%% imtool3DROI class
classdef imtool3DROI < handle
    %This is an abstract class for the ROI tools used in imtool3D
    
    %% Public Properties
    properties (SetObservable = true)
        imageHandle
        axesHandle
        figureHandle
        graphicsHandles
        menuHandles
        textHandle
        tool
        listenerHandle
        lineColor = 'y';
        markerColor = 'r';
        visible = true;
        textVisible = true; %this property is subordinate to visible (i.e., if visible is false, the text will not be visible even if textVisible is true)
    end
    
    %% Events
    events
        ROIdeleted
        newROIPosition
        newROIPositionUp
    end
    
    %% Public Class Methods
    methods
        %% Constructor
        function ROI = imtool3DROI(imageHandle,graphicsHandles,menuLabels,menuFunction,varargin)
            %Set the properties
            ROI.imageHandle = imageHandle;
            ROI.graphicsHandles = graphicsHandles;
            
            %Get the parent axes of the image
            ROI.axesHandle = get(imageHandle(1),'Parent');
            
            %Find the parent figure of the object
            ROI.figureHandle = getParentFigure(imageHandle(1));
            
            %create the context menu
            c = uicontextmenu;
            
            %set the graphics handles to use the context menu and set their
            %color
            if ROI.visible
                str = 'on';
            else
                str = 'off';
            end
            for i=1:length(graphicsHandles)
                set(graphicsHandles(i),'UIContextMenu',c)
                switch class(graphicsHandles(i))
                    case 'matlab.graphics.chart.primitive.Line'
                        set(graphicsHandles(i),'Color',ROI.lineColor,'MarkerFaceColor',ROI.markerColor,'MarkerEdgeColor',ROI.markerColor,'Visible',str)
                    case 'matlab.graphics.primitive.Rectangle'
                        set(graphicsHandles(i),'EdgeColor',ROI.lineColor,'Visible',str)
                    otherwise
                        disp(class(graphicsHandles(i)))
                end
                
            end
            
            %create each of the menu items and set their callback
            %functions
            menuFunction = @(source,callbackdata) menuFunction(source,callbackdata,ROI,varargin{:});
            for i=1:length(menuLabels)
                ROI.menuHandles(i) = uimenu('Parent',c,'Label',menuLabels{i},'Callback',menuFunction);
            end
        end
        
        %% set.lineColor
        % TODO: It would be appropriate to organize all of the class 
        % property getters/setters together in a contiguous block in the 
        % source file
        function set.lineColor(ROI,lineColor)
            ROI.lineColor = lineColor;
            
            % TODO: Fix the dependency of lineColor on the graphicsHandles
            % property
            graphicsHandles = ROI.graphicsHandles; %#ok<*PROPLC>
            for i=1:length(graphicsHandles)
                switch class(graphicsHandles(i))
                    case 'matlab.graphics.chart.primitive.Line'
                        set(graphicsHandles(i),'Color',ROI.lineColor)
                    case 'matlab.graphics.primitive.Rectangle'
                        set(graphicsHandles(i),'EdgeColor',ROI.lineColor)
                    otherwise
                        disp(class(graphicsHandles(i)))
                end
                
            end
        end
        
        %% set.markerColor
        % TODO: It would be appropriate to organize all of the class 
        % property getters/setters together in a contiguous block in the 
        % source file
        function set.markerColor(ROI,markerColor)
            ROI.markerColor = markerColor;
            
            % TODO: Fix the dependency on the graphicsHandles property
            graphicsHandles = ROI.graphicsHandles;
            for i=1:length(graphicsHandles)
                switch class(graphicsHandles(i))
                    case 'matlab.graphics.chart.primitive.Line'
                         set(graphicsHandles(i),'MarkerFaceColor',ROI.markerColor,'MarkerEdgeColor',ROI.markerColor)
                    otherwise
                        disp(class(graphicsHandles(i)))
                end
                
            end
        end
        
        %% set.visible
        % TODO: It would be appropriate to organize all of the class 
        % property getters/setters together in a contiguous block in the 
        % source file
        function set.visible(ROI,visible)
            ROI.visible=visible;
            if visible
                str = 'on';
            else
                str = 'off';
            end
            %turn on or off the visibility of the ROI graphics
            % TODO: Fix the dependency on the graphicsHandles property
            for i=1:length(ROI.graphicsHandles)
                set(ROI.graphicsHandles(i),'Visible',str);
            end
            
            %Turn on or off the visibility of the text box
            if visible
                % TODO: Fix the dependency on the textVisible property
                if ROI.textVisible
                    % TODO: Fix the dependency on the textHandle property
                    set(ROI.textHandle,'Visible','on');
                else
                    set(ROI.textHandle,'Visible','off');
                end
            else
                set(ROI.textHandle,'Visible','off');
            end
        end
        
        %% set.textVisible
        % TODO: It would be appropriate to organize all of the class 
        % property getters/setters together in a contiguous block in the 
        % source file
        function set.textVisible(ROI,textVisible)
            ROI.textVisible=textVisible;
            if textVisible
                % TODO: Fix the dependency on the textVisible property
                if ROI.visible
                    % TODO: Fix the dependency on the textHandle property
                    set(ROI.textHandle,'Visible','on');
                else
                    set(ROI.textHandle,'Visible','off');
                end
            else
                set(ROI.textHandle,'Visible','off');
                %make sure the context menu is in sync with this
                % TODO: Fix the dependency on the menuHandles property
                for i=1:length(ROI.menuHandles)
                    switch get(ROI.menuHandles(i),'Label')
                        case 'Hide Text'
                            set(ROI.menuHandles(i),'Checked','on');
                    end
                end
            end
        end
        
        %% Destructor
        function delete(ROI)
            try
                delete(ROI.graphicsHandles);
                delete(ROI.textHandle);
                delete(ROI.listenerHandle);
                notify(ROI,'ROIdeleted');
            catch ex
                warning(ex);
            end
        end
    end
end

%% Non-Class Helper Functions
% TODO: Consider whether these should really be separate or if they should
% be static methods of the class. If they don't belong in the class,
% perhaps they should be in a separate file.

%% getParentFigure
function fig = getParentFigure(fig)
% if the object is a figure or figure descendent, return the
% figure. Otherwise return [].
while ~isempty(fig) && ~strcmp('figure', get(fig,'type'))
  fig = get(fig,'parent');
end
end
