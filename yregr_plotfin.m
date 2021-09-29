function yregr_plotfin(yinp,ysel,compreg);
% function [yout,stats]=yregrnew(yinp,ysel,compreg)
% yout are the values predicted with the rgression constraint
% yinp are the y ALS values; ysel are the values coming from the csel matrix (reference concentrations)
% compreg is a binary vector setting which compounds should enter the regression process
%

if size(ysel)~=size(yinp)
    disp('dimensions of ysel and y are not the same; stop')
    return
end

totalcomp=sum(compreg);

[nr,nc]=size(yinp);
yout=yinp;
ycal=yinp;
stats=cell(1,nc);
for j=1:nc
    if compreg(j)==1
        isel=find(isfinite(ysel(:,j)));
        if isfinite(isel) & length(ysel(isel,j))>=2
            disp('regression for species: ');disp(j)
            x=ysel(isel,j);
            y=yinp(isel,j);
            [p,S]=polyfit(x,y,1);
            ycalc(:,j)=(yinp(:,j)-p(2))/p(1);
            
            subplot(totalcomp,1,j);
            plot(ysel(isel,j),ycalc(isel,j),'r*',ysel(isel,j),ysel(isel,j)),pause(0.5)
                        [p2,S2]=polyfit(ysel(isel,j),ycalc(isel,j),1);
            stind.slope=p2(1);
            stind.offset=p2(2);
            rcoef=corrcoef(ysel(isel,j),ycalc(isel,j));
            stind.r=rcoef(1,2);
%             stind.RMSEC=S2.normr/length(x); modified by Anna
            stind.RMSEC=S2.normr/sqrt(length(x));
            
            ycal(:,j)=ycalc(:,j);
            ycalc(isel,j)=ysel(isel,j);
            yout(:,j)=ycalc(:,j);
            stats{1,j}=stind;
            title(['species',num2str(j),',   r=',num2str(stind.r),',   RMSEC=',num2str(stind.RMSEC)]);
        end
    end
end


