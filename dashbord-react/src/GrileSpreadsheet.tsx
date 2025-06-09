import React, { useState } from 'react';
import { AgGridReact } from 'ag-grid-react';
import type { ColDef } from 'ag-grid-community';
import 'ag-grid-community/styles/ag-grid.css';
import 'ag-grid-community/styles/ag-theme-alpine.css';
import { Button } from '@/components/ui/button';

interface Sheet {
  name: string;
  columnDefs: ColDef[];
  rowData: Record<string, any>[];
}

export default function GrileSpreadsheet() {
  const [sheets, setSheets] = useState<Sheet[]>([
    {
      name: 'Sheet 1',
      columnDefs: [{ field: 'A', editable: true }],
      rowData: [{ A: '' }],
    },
  ]);
  const [active, setActive] = useState(0);
  const [rowHeight, setRowHeight] = useState(30);

  const addSheet = () => {
    setSheets((prev) => [
      ...prev,
      {
        name: `Sheet ${prev.length + 1}`,
        columnDefs: [{ field: 'A', editable: true }],
        rowData: [{ A: '' }],
      },
    ]);
    setActive(sheets.length);
  };

  const updateSheet = (index: number, update: Partial<Sheet>) => {
    setSheets((prev) => {
      const copy = [...prev];
      copy[index] = { ...copy[index], ...update } as Sheet;
      return copy;
    });
  };

  const addRow = () => {
    const current = sheets[active];
    const newRow: Record<string, any> = {};
    current.columnDefs.forEach((c) => {
      newRow[c.field as string] = '';
    });
    updateSheet(active, { rowData: [...current.rowData, newRow] });
  };

  const addColumn = () => {
    const current = sheets[active];
    const newField = `C${current.columnDefs.length + 1}`;
    const newCol: ColDef = { field: newField, editable: true };
    const newRowData = current.rowData.map((r) => ({ ...r, [newField]: '' }));
    updateSheet(active, {
      columnDefs: [...current.columnDefs, newCol],
      rowData: newRowData,
    });
  };

  const onCellValueChanged = (params: any) => {
    const { rowIndex, colDef, newValue } = params;
    updateSheet(active, {
      rowData: sheets[active].rowData.map((row, idx) =>
        idx === rowIndex ? { ...row, [colDef.field as string]: newValue } : row
      ),
    });
  };

  return (
    <div className="p-4 space-y-4">
      <div className="flex space-x-2">
        {sheets.map((s, i) => (
          <Button
            key={i}
            variant={active === i ? 'default' : 'secondary'}
            size="sm"
            onClick={() => setActive(i)}
          >
            {s.name}
          </Button>
        ))}
        <Button variant="ghost" size="sm" onClick={addSheet}>
          +
        </Button>
      </div>
      <div className="space-x-2">
        <Button size="sm" onClick={addRow}>
          Add Row
        </Button>
        <Button size="sm" onClick={addColumn}>
          Add Column
        </Button>
        <label className="ml-2 text-sm">
          Row height:
          <input
            type="number"
            value={rowHeight}
            onChange={(e) => setRowHeight(Number(e.target.value))}
            className="ml-1 border p-1 w-16 text-sm"
          />
        </label>
      </div>
      <div className="ag-theme-alpine" style={{ width: '100%', height: 500 }}>
        <AgGridReact
          columnDefs={sheets[active].columnDefs}
          rowData={sheets[active].rowData}
          defaultColDef={{ editable: true, resizable: true, filter: true }}
          onCellValueChanged={onCellValueChanged}
          rowHeight={rowHeight}
        />
      </div>
    </div>
  );
}
