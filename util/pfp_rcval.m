function [val] = pfp_rcval(rcd, rid, cid)
    %PFP_RCVAL Row-col value
    %
    % [val] = PFP_RCVAL(rcd);
    %
    %   Returns the data value indexed by "row" and "col" ID.
    %
    % Input
    % -----
    % [struct]
    % rcd:  The row-col-data structure,
    %       .row  [cell]    - row ID
    %       .col  [cell]    - column ID
    %       .data [double]  - value
    %
    % [char]
    % rid:  The row ID.
    %
    % [char]
    % cid:  The column ID.
    %
    % Output
    % ------
    % [double]
    % val:  The indexed value.

    % check inputs {{{
    if nargin ~= 3
        error('pfp_rcval:InputCount', 'Expected 3 inputs.');
    end

    % rcd
    validateattributes(rcd, {'struct'}, {'nonempty'}, '', 'rcd', 1);

    % rid
    validateattributes(rid, {'char'}, {'nonempty'}, '', 'rid', 2);

    % cid
    validateattributes(cid, {'char'}, {'nonempty'}, '', 'cid', 3);
    % }}}

    % retrieve value {{{
    [rfound, rindex] = ismember(rid, rcd.row);
    [cfound, cindex] = ismember(cid, rcd.col);
    if (~rfound) | (~cfound)
        val = NaN;
    else
        val = full(rcd.data(rindex, cindex));
    end
    % }}}
end

% -------------
% Yuxiang Jiang (yuxjiang@indiana.edu)
% Department of Computer Science
% Indiana University, Bloomington
% Last modified: Wed 21 Sep 2016 02:36:01 PM E
