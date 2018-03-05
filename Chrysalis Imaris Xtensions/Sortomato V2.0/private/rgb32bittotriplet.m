function varargout = rgb32bittotriplet(bin32value)
    % RGB32BITTOTRIPLET Convert a binary 32-bit color value into an RGB triplet
    %   RGB32BITTOTRIPLET converts the 32-bit number representing an RGB color
    %   with transparency into an RGB triplet and alpha (transparency) value.
    %
    %   Syntax
    %   ------
    %   rgbTriplet = RGB32BITTOTRIPLET(singleValue);
    %   [rgbTriplet, alphaValue] = RGB32BITTOTRIPLET(singleValue);
    %
    %   Description
    %   -----------
    %   rgbTriplet = RGB32BITTOTRIPLET(singleValue) returns the RGB triplet
    %   identified by the 24- or 32-bit binary value singleValue.
    %
    %   [rgbTriplet, alphaValue] = RGB32BITTOTRIPLET(singleValue) returns
    %   the RGB triplet and the transparency from the 32-bit binary value
    %   singleValue.    
    %
    %   ©2013, P. Beemiller. Licensed under a Creative Commmons Attribution
    %   license. Please see: http://creativecommons.org/licenses/by/3.0/

    %% Allocate the triplet array.
    varargout{1} = zeros(1, 3, 'double');

    %% Calculate the color components.
    varargout{1}(1) = rem(bin32value, 256)/255;

    % Get the second through fourth bytes.
    bytes2to4 = floor(bin32value/256);

    % Calculate the green component.
    varargout{1}(2) = rem(bytes2to4, 256)/255;

    % Get the third and fourth byte.
    bytes3to4 = floor(bytes2to4/256);

    % Calculate the blue component.
    varargout{1}(3) = rem(bytes3to4, 256)/255;

    % Get the fourth byte, if requested.
    if nargout == 2
        byte4 = floor(bytes3to4/256);

        % Calculate the alpha component.
        varargout{2} = rem(byte4, 256)/256;
    end % if
end % rgb32bittotriplet