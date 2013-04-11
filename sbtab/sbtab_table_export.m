function tt = sbtab_table_export(sbtab_struct,filename)

% tt = sbtab_table_export(sbtab_struct,filename)
%
% turn sbtab structure into flat table

columns = fieldnames(sbtab_struct);

clear tt

for it = 1:length(columns)
  val = getfield(sbtab_struct,columns{it});
  if isnumeric(val(1));
      tt(:,it) = cellstr(num2str(val));
      for itt = 1:length(tt(:,it)),
      tt(itt,it) = strrep(tt(itt,it),' ','');
      end
    else,
      tt(:,it) = val;
  end
end

tt = [columns'; tt];

if exist('filename','var'), 
  table(tt,0,filename);
else
  table(tt,0);
end
