function dist = getDistPCK(pred,gt,dataset)

if strcmp(dataset, 'flic')
    assert(size(pred,1) == size(gt,1) && size(pred,2) == size(gt,2)-1 && size(pred,3) == size(gt,3));
else
    assert(size(pred,1) == size(gt,1) && size(pred,2) == size(gt,2) && size(pred,3) == size(gt,3));
end

dist = nan(1,size(pred,2),size(pred,3));

for imgidx = 1:size(pred,3)
    
    % torso diameter
    if strcmp(dataset, 'flic')
        refDist = norm(gt(:,end,imgidx));
        gt_ = gt(:,1:11,:);
    else        
        refDist = norm(gt(:,10,imgidx) - gt(:,3,imgidx));
        gt_ = gt;
    end
    
    % distance to gt joints
    dist(1,:,imgidx) = sqrt(sum((pred(:,:,imgidx) - gt_(:,:,imgidx)).^2,1))./refDist;
end