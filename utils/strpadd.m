function str_padd = strpadd(str, char, n, opt)
% Pad a string with any character. The ammount of padding is defined by
% 'n', and 'opt' indicates how to pad the string.
    switch opt
        case 0
            % pad right
            str_padd = [str repmat(char,1,n-length(str))];
        case 1
            % pad left
            str_padd = [repmat(char,1,n-length(str)) str];
        case 2
            % pad left & right
            len_l = floor((n-length(str))/2);
            len_r = ceil((n-length(str))/2);
            str_padd = [repmat(char,1,len_l) str repmat(char,1,len_r)];
        otherwise
            % pad right
            str_padd = [str repmat(char,1,n-length(str))];
    end
end