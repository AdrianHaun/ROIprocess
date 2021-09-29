function [yout,ycal,stats]=yregrnew(yinp,ysel,compreg);
% function [yout,stats]=yregrnew(yinp,ysel,compreg)
% yout are the values predicted with the rgression constraint
% yinp are the y ALS values; ysel are the values coming from the csel matrix (reference concentrations)
% compreg is a binary vector setting which compounds should enter the regression process

if size(ysel)~=size(yinp)
    disp('dimensions of ysel and y are not the same; stop')
    return
end

[nr,nc]=size(yinp);
yout=yinp;
ycal=yinp;
stats=cell(1,nc);
sp_regression=sum(compreg);
actual=1;

for j=1:nc
    if compreg(j)==1
        isel=find(isfinite(ysel(:,j)));
        if isfinite(isel) & length(ysel(isel,j))>=2
            
            %           disp('regression for species: ');disp(j)
            x=ysel(isel,j); % reference values
            y=yinp(isel,j); % ALS values
            
            % performing correlation/regression
            [p,S]=polyfit(x,y,1);
            
            ycalc(:,j)=(yinp(:,j)-p(2))/p(1);% recalculation of ALS values according regression to reference values
            
            if evalin('base','mcr_als.alsOptions.opt.gr')=='y',
                figure(1);
                subplot(sp_regression,1,actual);
                plot(ysel(isel,j),ycalc(isel,j),'r*',ysel(isel,j),ysel(isel,j)),pause(0.05)
            end
            
            [p2,S2]=polyfit(ysel(isel,j),ycalc(isel,j),1);
            
            stind.slope=p2(1);
            stind.offset=p2(2);
            rcoef=corrcoef(ysel(isel,j),ycalc(isel,j));
            stind.r=rcoef(1,2);
            stind.RMSEC=S2.normr/sqrt(length(x));
            dev=ysel(isel,j)-ycalc(isel,j);
            erel=100*sqrt(dev'*dev/(ysel(isel,j)'*ysel(isel,j))); % relative error also useful to know
            stind.erel=erel;
            
            % update recalculated values
            ycal(:,j)=ycalc(:,j);
            ycalc(isel,j)=ysel(isel,j);
            yout(:,j)=ycalc(:,j);
            
            stats{1,j}=stind;
            disp('statistics of correlation:');disp(stind)
            
            if evalin('base','mcr_als.alsOptions.opt.gr')=='y',
                title(['species',num2str(j),',   r=',num2str(stind.r),',   RMSEC=',num2str(stind.RMSEC)]);
            end
            actual=actual+1;
            
        end
    end
end










