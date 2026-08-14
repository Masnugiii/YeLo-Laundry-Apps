"use client";

import { useMemo, useState } from "react";

import { Card, CardTitle, CardValue } from "@/components/ui/card";
import { EmptyState, QueryErrorState } from "@/components/orders/list-states";
import { useLaciLaundryDashboard, useLaciLaundryLockers } from "@/hooks/use-laci-laundry";
import { getErrorMessage } from "@/lib/errors";
import type { StorageBoxSummary } from "@/types/laci-laundry";

export default function LaciLaundryPage() {
  const [search, setSearch] = useState("");
  const [filter, setFilter] = useState<"all" | "available" | "occupied" | "ready_for_pickup">("all");
  const [selectedBox, setSelectedBox] = useState<StorageBoxSummary | null>(null);

  const dashboardQuery = useLaciLaundryDashboard();
  const lockersQuery = useLaciLaundryLockers();

  const filteredLockers = useMemo(() => {
    const lockers = lockersQuery.data ?? [];
    const q = search.trim().toLowerCase();

    return lockers.map((locker) => {
      const boxes = locker.boxes.filter((box) => {
        if (filter === "available" && box.status !== "AVAILABLE") return false;
        if (filter === "occupied" && box.status !== "OCCUPIED") return false;
        if (
          filter === "ready_for_pickup" &&
          !box.orders.some((order) => order.orderStatus === "READY_FOR_PICKUP")
        ) {
          return false;
        }
        if (!q) return true;
        return (
          box.code.toLowerCase().includes(q) ||
          locker.code.toLowerCase().includes(q) ||
          locker.name.toLowerCase().includes(q) ||
          box.orders.some(
            (order) =>
              order.orderNumber.toLowerCase().includes(q) ||
              order.customerName.toLowerCase().includes(q) ||
              (order.customerPhone ?? "").toLowerCase().includes(q),
          )
        );
      });
      return { ...locker, boxes };
    });
  }, [filter, lockersQuery.data, search]);

  if (dashboardQuery.isLoading || lockersQuery.isLoading) {
    return <div className="p-6 text-sm text-muted-foreground">Memuat Laci Laundry...</div>;
  }

  if (dashboardQuery.error || lockersQuery.error) {
    return (
      <QueryErrorState
        title="Gagal memuat data laci"
        message={getErrorMessage(dashboardQuery.error ?? lockersQuery.error, "Gagal memuat data laci")}
        onRetry={() => {
          void dashboardQuery.refetch();
          void lockersQuery.refetch();
        }}
      />
    );
  }

  const dashboard = dashboardQuery.data;

  return (
    <div className="space-y-6 p-6">
      <div>
        <h1 className="text-2xl font-semibold">Laci Laundry</h1>
        <p className="text-sm text-muted-foreground">
          Monitoring lokasi penyimpanan laundry (read-only)
        </p>
      </div>

      <div className="grid gap-4 md:grid-cols-4">
        <Card>
          <CardTitle>Total Laci</CardTitle>
          <CardValue>{dashboard?.totalLockers ?? 3}</CardValue>
        </Card>
        <Card>
          <CardTitle>Total Kotak</CardTitle>
          <CardValue>{dashboard?.totalBoxes ?? 39}</CardValue>
        </Card>
        <Card>
          <CardTitle>Order Dalam Storage</CardTitle>
          <CardValue>{dashboard?.totalOrdersInStorage ?? 0}</CardValue>
        </Card>
        <Card>
          <CardTitle>Kosong / Terisi</CardTitle>
          <CardValue>
            {dashboard?.availableCount ?? 0} / {dashboard?.occupiedCount ?? 0}
          </CardValue>
        </Card>
      </div>

      <div className="flex flex-col gap-3 md:flex-row">
        <input
          className="h-10 flex-1 rounded-md border px-3 text-sm"
          placeholder="Cari laci, kotak, order, customer, atau HP"
          value={search}
          onChange={(event) => setSearch(event.target.value)}
        />
        <select
          className="h-10 rounded-md border px-3 text-sm"
          value={filter}
          onChange={(event) => setFilter(event.target.value as typeof filter)}
        >
          <option value="all">Semua</option>
          <option value="available">Kosong</option>
          <option value="occupied">Terisi</option>
          <option value="ready_for_pickup">Ready For Pickup</option>
        </select>
      </div>

      {filteredLockers.every((locker) => locker.boxes.length === 0) ? (
        <EmptyState
          title="Tidak ada kotak ditemukan"
          description="Coba ubah filter atau kata kunci pencarian."
        />
      ) : (
        filteredLockers.map((locker) => (
          <section key={locker.code} className="rounded-xl border bg-white p-4">
            <div className="mb-4">
              <h2 className="text-lg font-semibold">{locker.name}</h2>
              <p className="text-sm text-muted-foreground">
                {locker.totalBoxes} kotak · {locker.availableCount} kosong · {locker.occupiedCount}{" "}
                terisi · {locker.orderCount} order
              </p>
            </div>
            <div className="grid grid-cols-2 gap-3 sm:grid-cols-4 lg:grid-cols-6">
              {locker.boxes.map((box) => (
                <BoxCard key={box.id} box={box} onSelect={() => setSelectedBox(box)} />
              ))}
            </div>
          </section>
        ))
      )}

      {selectedBox ? (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
          <div className="max-h-[85vh] w-full max-w-lg overflow-y-auto rounded-xl bg-white p-6 shadow-xl">
            <div className="mb-4 flex items-start justify-between gap-4">
              <div>
                <h3 className="text-xl font-semibold">{selectedBox.code}</h3>
                <p className="text-sm text-muted-foreground">
                  {selectedBox.lockerName} · Kotak {String(selectedBox.boxNumber).padStart(2, "0")}
                </p>
              </div>
              <button
                type="button"
                className="rounded-md border px-3 py-1 text-sm"
                onClick={() => setSelectedBox(null)}
              >
                Tutup
              </button>
            </div>
            <p className="mb-4 text-sm font-medium">
              {selectedBox.statusLabel} · {selectedBox.orderCount} order
            </p>
            {selectedBox.orders.length === 0 ? (
              <p className="text-sm text-muted-foreground">Tidak ada order aktif di kotak ini.</p>
            ) : (
              <div className="space-y-3">
                {selectedBox.orders.map((order, index) => (
                  <div key={order.id} className="rounded-lg border p-3">
                    <p className="text-xs text-muted-foreground">#{index + 1}</p>
                    <p className="font-semibold">{order.customerName}</p>
                    <p className="text-sm">{order.orderNumber}</p>
                    <p className="text-xs text-muted-foreground">{order.orderStatus}</p>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      ) : null}
    </div>
  );
}

function BoxCard({
  box,
  onSelect,
}: {
  box: StorageBoxSummary;
  onSelect: () => void;
}) {
  const occupied = box.status === "OCCUPIED";
  return (
    <button
      type="button"
      onClick={onSelect}
      className={`rounded-lg border p-3 text-left transition hover:shadow-sm ${
        occupied ? "border-amber-300 bg-amber-50" : "border-emerald-200 bg-emerald-50"
      }`}
    >
      <div className="text-base font-semibold">{String(box.boxNumber).padStart(2, "0")}</div>
      <div className="text-xs font-medium">{occupied ? "TERISI" : "KOSONG"}</div>
      {occupied ? (
        <div className="mt-2 text-xs font-semibold">
          {box.orderCount} ORDER
        </div>
      ) : null}
    </button>
  );
}
