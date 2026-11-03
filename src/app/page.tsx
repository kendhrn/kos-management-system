import { logout } from "./login/actions";

export default function Home() {
  return (
    <main className="flex flex-1 flex-col items-center justify-center gap-4 p-6 text-center">
      <h1 className="text-3xl font-bold">Kos Management System</h1>
      <p className="text-zinc-600 dark:text-zinc-400">
        Aplikasi pengelolaan kos sedang dalam pengembangan.
      </p>
      <form action={logout}>
        <button
          type="submit"
          className="rounded-md border border-gray-300 px-4 py-2 text-sm"
        >
          Keluar
        </button>
      </form>
    </main>
  );
}
