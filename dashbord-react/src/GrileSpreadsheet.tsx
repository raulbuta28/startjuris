import React, { useState } from "react";
import Spreadsheet, { CellBase } from "react-spreadsheet";
import { Button } from "@/components/ui/button";

interface Sheet {
  name: string;
  data: CellBase[][];
}

export default function GrileSpreadsheet() {
  const [sheets, setSheets] = useState<Sheet[]>([
    { name: "Sheet 1", data: [[{ value: "" }]] },
  ]);
  const [active, setActive] = useState(0);

  const addSheet = () => {
    setSheets((prev) => [
      ...prev,
      { name: `Sheet ${prev.length + 1}`, data: [[{ value: "" }]] },
    ]);
    setActive(sheets.length);
  };

  const updateSheet = (index: number, data: CellBase[][]) => {
    setSheets((prev) => {
      const copy = [...prev];
      copy[index] = { ...copy[index], data };
      return copy;
    });
  };

  return (
    <div className="p-4 space-y-4">
      <div className="flex space-x-2">
        {sheets.map((s, i) => (
          <Button
            key={i}
            variant={active === i ? "default" : "secondary"}
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
      <Spreadsheet
        data={sheets[active].data}
        onChange={(d) => updateSheet(active, d)}
      />
    </div>
  );
}
