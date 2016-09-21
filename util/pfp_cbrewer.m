function [cs] = pfp_cbrewer(n, theme)
    %PFP_CBREWER Color brewer
    %
    % [cs] = PFP_CBREWER(n);
    %
    %   Creates a color scheme for plotting.
    %
    % Note
    % ----
    % This function takes color map generated from colorbrewer2.org and manually
    % pick a pair of color maps (as "light" and "normal") for each 'n'.
    %
    % Input
    % -----
    % n:    The number of color needed. n must be less than or equal to 12.
    %
    % (optional)
    % theme:    One of {'light', 'normal'}
    %           default: normal
    %
    % Output
    % ------
    % cs:   An n-by-3 matrix of color scheme (RGB tuples).
    %
    % Reference
    % ---------
    % colorbrewer2.org | Cynthia Brewer, Mark Harrower and Penn State U.

    % checking {{{
    if n > 12
        error('pfp_cbrewer:OutOfRange', 'The number of colors must be <= 12.');
    end

    if ~exist('theme', 'var');
        theme = 'normal';
    end
    % }}}

    % the "light" theme {{{
    ltheme = [...
        251, 128, 114; ...
        128, 177, 211; ...
        141, 211, 199; ...
        253, 180, 098; ...
        179, 222, 105; ...
        252, 205, 229; ...
        190, 186, 218; ...
        217, 217, 217; ...
        255, 255, 179; ...
        188, 128, 189; ...
        204, 235, 197; ...
        255, 237, 111; ...
        ] ./ 255;
    % }}}

    % the "normal" theme {{{
    ntheme = [...
        227, 026, 028; ...
        031, 120, 180; ...
        051, 160, 044; ...
        255, 127, 000; ...
        251, 154, 153; ...
        166, 206, 227; ...
        255, 255, 153; ...
        202, 178, 214; ...
        178, 223, 138; ...
        106, 061, 154; ...
        253, 191, 111; ...
        177, 089, 040; ...
        ] ./ 255;
    % }}}

    % generating {{{
    switch lower(theme)
        case {'normal', 'nor', 'n'}
            cs = ntheme(1 : n, :);
        case {'light', 'lig', 'l'}
            cs = ltheme(1 : n, :);
        otherwise
            error('pfp_cbrewer:UnknownTheme', 'Unknown color theme.');
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University Bloomington
% Last modified: Wed 21 Sep 2016 02:26:45 PM E
