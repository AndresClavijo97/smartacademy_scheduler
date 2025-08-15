class ScheduleModalPage < ApplicationPage
  private attr_reader :data

  def find_next_available_class
    within_schedule_frame do    
      execute_js
    end
  end

  private

  def execute_js
    @data = page.evaluate_script(extract_rows_js)
  end

  def within_schedule_frame(&block)
    within_frame(find('#gxp0_ifrm')) do
      yield
    end
  end


  def extract_rows_js
    <<~JS
      (() => {
        const rows = document.querySelectorAll('tr[id*="Grid1ContainerRow"]');
        console.log('JS: Found', rows.length, 'rows');
        
        return Array.from(rows).map((row, index) => {
          const cells = Array.from(row.querySelectorAll('td'));
          
          return {
            rowIndex: index + 1,
            rowId: row.id,
            cellCount: cells.length,
            nivel: cells[0] ? cells[0].textContent.trim() : '',
            claseNo: cells[1] ? cells[1].textContent.trim() : '',
            resumenDescripcion: cells[2] ? cells[2].textContent.trim() : '',
            nota: cells[3] ? cells[3].textContent.trim() : '',
            aprobo: cells[4] ? cells[4].textContent.trim() : '',
            estado: cells[5] ? cells[5].textContent.trim() : '',
            fechaClase: cells[6] ? cells[6].textContent.trim() : '',
            nombreSede: cells[7] ? cells[7].textContent.trim() : '',
            allCells: cells.map(cell => cell.textContent.trim()),
            fullText: row.textContent.trim()
          };
        });
      })();
    JS
  end
end