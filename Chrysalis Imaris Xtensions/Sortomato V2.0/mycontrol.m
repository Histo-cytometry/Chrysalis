classdef mycontrol < dynamicprops
    % MYCONTROL A simple container class for uicontrol objects
    %
    %   Syntax
    %   ------
    %   editControl = mycontrol('Style', 'edit', 'String', 1);
    %   popupControl = mycontrol('Style', 'popup', 'String', {'Door #1', ...
    %       'Door #2', 'Door #1'});
    %
    %   MYCONTROL directly passes input arguments to uicontrol. As a
    %   result, the syntax to create a MYCONTROL object is identical to
    %   uicontrol.
    %
    %   MYCONTROL creates a uicontrol object and stores it in a MYCONTROL
    %   wrapper object. MYCONTROL adds staic properties for recording old
    %   string and value properties. These can be used for restoring values
    %   that fail to meet criteria. Because mycontrol is derived from the
    %   dynamicprops class, you can also add properties to track other
    %   values.
    %
    %   MYCONTROL objects can be accessed like uicontrol by replacing the
    %   handle reference with a reference to the .Handle property of the
    %   MYCONTROL object.
    %
    %   Accessing and setting a uicontrol property.
    %   hUIControl = uicontrol('Style', 'edit', 'String', 'stringData');
    %   uiString = get(hUIControl, 'String');
    %   set(hUIControl, 'Value', 1)
    %
    %   Accessing and setting a MYCONTROL property.
    %   hMyControl = mycontrol('Style', 'edit', 'String', 'stringData');
    %   uiString = get(hMyControl.Handle, 'String');
    %   set(hMyControl.Handle, 'Value', 1);
    %
    %   ©2010-2013, P. Beemiller. Licensed under a Creative Commmons Attribution
    %   license. Please see: http://creativecommons.org/licenses/by/3.0/
    %
    
    properties
        
        Handle
        OldString
        OldValue
        
    end % properties
    
    methods % methods

        % Constructor function.
        function obj = mycontrol(varargin)
            obj.Handle = uicontrol(varargin{:});
            obj.setOldString(get(obj.Handle, 'String'));
            obj.setOldValue(get(obj.Handle, 'Value'));
        end % mycontrol
        
        function obj = setOldString(obj, oldString)
            obj.OldString = oldString;
        end %setOldString

        function obj = setOldValue(obj, oldValue)
            obj.OldValue = oldValue;
        end %setOldValue
                
    end % methods
    
    events
        
    end % events
    
end % mycontrol