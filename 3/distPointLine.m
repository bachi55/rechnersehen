function d = distPointLine (p, l)
    l = l ./ norm (l(1:2));
    p = p ./ p(3);
    d = p' * l;
end % function