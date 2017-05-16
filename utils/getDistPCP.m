function dist = getDistPCP(pred,gt,dataset)

if strcmpi(dataset, 'flic')
    assert(size(pred,1) == size(gt,1) && size(pred,2) == 10 && size(gt,2)-1 == 11 && size(pred,3) == size(gt,3));
    % convert joint annotations into sticks
    gt_sticks = keypoints2sticksFLIC(gt);
    assert(size(gt_sticks,2) == 10);
    assert(size(pred,1) == size(gt_sticks,1) && size(pred,2) == size(gt_sticks,2) && size(pred,3) == size(gt_sticks,3));

elseif strcmpi(dataset,'lsp')
    assert(size(pred,1) == size(gt,1) && size(pred,2) == 20 && size(gt,2) == 14 && size(pred,3) == size(gt,3));
    % convert joint annotations into sticks
    gt_sticks = keypoints2sticksLSP(gt);
    assert(size(gt_sticks,2) == 20);
    assert(size(pred,1) == size(gt_sticks,1) && size(pred,2) == size(gt_sticks,2) && size(pred,3) == size(gt_sticks,3));
end

dist = nan(1,size(pred,2),size(pred,3));

for imgidx = 1:size(pred,3)
    for jidx = 1:size(gt_sticks,2)/2
        jidx1 = 2*(jidx-1)+1;
        jidx2 = 2*(jidx-1)+2;
        % distance to gt endpoints
        dist(1,jidx1,imgidx) = norm(gt_sticks(:,jidx1,imgidx) - pred(:,jidx1,imgidx))/norm(gt_sticks(:,jidx1,imgidx) - gt_sticks(:,jidx2,imgidx));
        dist(1,jidx2,imgidx) = norm(gt_sticks(:,jidx2,imgidx) - pred(:,jidx2,imgidx))/norm(gt_sticks(:,jidx1,imgidx) - gt_sticks(:,jidx2,imgidx));
    end
end