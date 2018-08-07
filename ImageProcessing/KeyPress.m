function KeyPress(ObjH, EventData)
h = guidata(gcbo);
h.key = EventData.Key;
% % switch EventData.Key
% %     case 'leftarrow'
% %         disp('Back');
% %         
% %     case 'rightarrow'
% %         disp('Next');
% %         h.brk_count(h.ii) = 0;
% %         
% %     case 'space'
% %         disp('Count it!')
% %         h.brk_count(h.ii) = 1;
% %         
% %     otherwise
% %         disp('Exit')
% %         h.exit = 1;
% % end

  uiresume(gcf)
  guidata(gcbo,h) 
end