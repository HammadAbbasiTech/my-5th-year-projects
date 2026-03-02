#define _CRT_SECURE_NO_WARNINGS
#include <iostream>
#include <iomanip>
#include <vector>
#include <algorithm>
#include <queue>
#include <ctime>
#include <filesystem>
#include <fstream>
#include <thread>
#include <limits>

using namespace std;
namespace fs = std::filesystem;

// -------------------- GLOBALS --------------------
vector<string> historyCmd;

// -------------------- STRUCT --------------------
struct Process {
    int pid, at, bt, ct, tat, wt, rt, remaining;
};

// -------------------- UTILITIES --------------------
void clearScreen() {
    system("cls");
}

void showTime() {
    time_t now = time(0);
    char buf[26];
    ctime_s(buf, sizeof(buf), &now);
    cout << "Date & Time: " << buf << endl;
}

void printTable(vector<Process>& p) {
    float awt = 0, atat = 0;

    cout << "\n------------------------------------------------------------\n";
    cout << "PID\tAT\tBT\tCT\tTAT\tWT\tRT\n";
    cout << "------------------------------------------------------------\n";

    for (auto& x : p) {
        cout << x.pid << "\t"
            << x.at << "\t"
            << x.bt << "\t"
            << x.ct << "\t"
            << x.tat << "\t"
            << x.wt << "\t"
            << x.rt << endl;

        awt += x.wt;
        atat += x.tat;
    }

    cout << "------------------------------------------------------------\n";
    cout << "Average Waiting Time   : " << awt / p.size() << endl;
    cout << "Average Turnaround Time: " << atat / p.size() << endl;
    cout << "------------------------------------------------------------\n";
}

// -------------------- FCFS --------------------
void FCFS() {
    int n;
    cout << "Enter number of processes: ";
    cin >> n;

    vector<Process> p(n);

    for (int i = 0; i < n; i++) {
        p[i].pid = i + 1;
        cout << "AT & BT for P" << i + 1 << ": ";
        cin >> p[i].at >> p[i].bt;
    }

    sort(p.begin(), p.end(), [](const Process& a, const Process& b) {
        return a.at < b.at;
        });

    int time = 0;

    for (auto& x : p) {
        if (time < x.at)
            time = x.at;

        x.rt = time - x.at;
        time += x.bt;
        x.ct = time;
        x.tat = x.ct - x.at;
        x.wt = x.tat - x.bt;
    }

    printTable(p);
}

// -------------------- SJF NON-PREEMPTIVE --------------------
void SJF_NP() {
    int n;
    cout << "Enter number of processes: ";
    cin >> n;

    vector<Process> p(n);
    vector<bool> done(n, false);

    for (int i = 0; i < n; i++) {
        p[i].pid = i + 1;
        cout << "AT & BT for P" << i + 1 << ": ";
        cin >> p[i].at >> p[i].bt;
    }

    int completed = 0;
    int time = 0;

    while (completed < n) {
        int idx = -1;
        int minBT = numeric_limits<int>::max();

        for (int i = 0; i < n; i++) {
            if (!done[i] && p[i].at <= time && p[i].bt < minBT) {
                minBT = p[i].bt;
                idx = i;
            }
        }

        if (idx == -1) {
            time++;
            continue;
        }

        p[idx].rt = time - p[idx].at;
        time += p[idx].bt;
        p[idx].ct = time;
        p[idx].tat = p[idx].ct - p[idx].at;
        p[idx].wt = p[idx].tat - p[idx].bt;

        done[idx] = true;
        completed++;
    }

    printTable(p);
}

// -------------------- ROUND ROBIN --------------------
void RoundRobin() {
    int n, tq;
    cout << "Enter number of processes: ";
    cin >> n;

    cout << "Enter Time Quantum: ";
    cin >> tq;

    vector<Process> p(n);
    queue<int> q;
    vector<bool> inQueue(n, false);

    for (int i = 0; i < n; i++) {
        p[i].pid = i + 1;
        cout << "AT & BT for P" << i + 1 << ": ";
        cin >> p[i].at >> p[i].bt;

        p[i].remaining = p[i].bt;
        p[i].rt = -1;
    }

    int time = 0;
    int completed = 0;

    while (completed < n) {
        for (int i = 0; i < n; i++) {
            if (p[i].at <= time && !inQueue[i] && p[i].remaining > 0) {
                q.push(i);
                inQueue[i] = true;
            }
        }

        if (q.empty()) {
            time++;
            continue;
        }

        int i = q.front();
        q.pop();

        if (p[i].rt == -1)
            p[i].rt = time - p[i].at;

        int exec = min(tq, p[i].remaining);
        time += exec;
        p[i].remaining -= exec;

        if (p[i].remaining > 0) {
            q.push(i);
        }
        else {
            p[i].ct = time;
            p[i].tat = p[i].ct - p[i].at;
            p[i].wt = p[i].tat - p[i].bt;
            completed++;
        }
    }

    printTable(p);
}

// -------------------- BANKER'S ALGORITHM --------------------
void Bankers() {
    int n, m;
    cout << "Processes: ";
    cin >> n;

    cout << "Resources: ";
    cin >> m;

    vector<vector<int>> alloc(n, vector<int>(m));
    vector<vector<int>> max(n, vector<int>(m));
    vector<vector<int>> need(n, vector<int>(m));
    vector<int> avail(m);

    cout << "Allocation Matrix:\n";
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            cin >> alloc[i][j];

    cout << "Max Matrix:\n";
    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            cin >> max[i][j];

    cout << "Available Resources:\n";
    for (int i = 0; i < m; i++)
        cin >> avail[i];

    for (int i = 0; i < n; i++)
        for (int j = 0; j < m; j++)
            need[i][j] = max[i][j] - alloc[i][j];

    vector<bool> finish(n, false);
    vector<int> safe;

    for (int k = 0; k < n; k++) {
        for (int i = 0; i < n; i++) {
            if (!finish[i]) {
                bool canRun = true;

                for (int j = 0; j < m; j++)
                    if (need[i][j] > avail[j])
                        canRun = false;

                if (canRun) {
                    for (int j = 0; j < m; j++)
                        avail[j] += alloc[i][j];

                    safe.push_back(i);
                    finish[i] = true;
                }
            }
        }
    }

    if (safe.size() == n) {
        cout << "SAFE STATE\nSequence: ";
        for (int x : safe)
            cout << "P" << x << " ";
        cout << endl;
    }
    else {
        cout << "UNSAFE STATE\n";
    }
}

// -------------------- LINUX COMMANDS --------------------
void pwd() {
    cout << fs::current_path() << endl;
}

void ls() {
    for (auto& p : fs::directory_iterator("."))
        cout << p.path().filename() << endl;
}

void mkdirCmd() {
    string n;
    cout << "Dir name: ";
    cin >> n;
    fs::create_directory(n);
}

void rmdirCmd() {
    string n;
    cout << "Dir name: ";
    cin >> n;
    fs::remove(n);
}

void touchCmd() {
    string n;
    cout << "File name: ";
    cin >> n;
    ofstream(n).close();
}

void catCmd() {
    string n, s;
    cout << "File name: ";
    cin >> n;

    ifstream f(n);
    if (!f) {
        cout << "File not found\n";
        return;
    }

    cin.ignore(numeric_limits<streamsize>::max(), '\n');
    while (getline(f, s))
        cout << s << endl;
}

void rmCmd() {
    string n;
    cout << "File name: ";
    cin >> n;
    fs::remove(n);
}

void echoCmd() {
    cin.ignore(numeric_limits<streamsize>::max(), '\n');
    string s;
    getline(cin, s);
    cout << s << endl;
}

void sleepCmd() {
    int s;
    cout << "Seconds: ";
    cin >> s;
    this_thread::sleep_for(chrono::seconds(s));
}

void uname() {
    cout << "MiniLinuxOS v1.0 (Windows Compatible)\n";
}

void history() {
    for (int i = 0; i < historyCmd.size(); i++)
        cout << i + 1 << ": " << historyCmd[i] << endl;
}

// -------------------- MAIN --------------------
int main() {
    string cmd;

    cout << "🐧 Mini Linux OS Console\n";
    cout << "User: hammad\n";
    cout << "Type 'help'\n\n";

    while (true) {
        cout << ">> ";
        cin >> cmd;

        historyCmd.push_back(cmd);

        if (cmd == "fcfs")     FCFS();
        else if (cmd == "sjfnp")    SJF_NP();
        else if (cmd == "rr")       RoundRobin();
        else if (cmd == "bankers")  Bankers();
        else if (cmd == "pwd")      pwd();
        else if (cmd == "ls")       ls();
        else if (cmd == "mkdir")    mkdirCmd();
        else if (cmd == "rmdir")    rmdirCmd();
        else if (cmd == "touch")    touchCmd();
        else if (cmd == "cat")      catCmd();
        else if (cmd == "rm")       rmCmd();
        else if (cmd == "echo")     echoCmd();
        else if (cmd == "sleep")    sleepCmd();
        else if (cmd == "uname")    uname();
        else if (cmd == "history")  history();
        else if (cmd == "date")     showTime();
        else if (cmd == "clear")    clearScreen();
        else if (cmd == "whoami")   cout << "hammad\n";
        else if (cmd == "help") {
            cout << "\nAvailable commands:\n";
            cout << "fcfs       - First Come First Serve Scheduling\n";
            cout << "sjfnp      - Shortest Job First (Non-Preemptive)\n";
            cout << "rr         - Round Robin Scheduling\n";
            cout << "bankers    - Banker's Algorithm\n";
            cout << "pwd        - Show current directory\n";
            cout << "ls         - List files\n";
            cout << "mkdir      - Create directory\n";
            cout << "rmdir      - Remove directory\n";
            cout << "touch      - Create file\n";
            cout << "cat        - View file content\n";
            cout << "rm         - Delete file\n";
            cout << "echo       - Print text\n";
            cout << "sleep      - Pause execution\n";
            cout << "uname      - System info\n";
            cout << "history    - Command history\n";
            cout << "date       - Show date & time\n";
            cout << "clear      - Clear screen\n";
            cout << "whoami     - Show user\n";
            cout << "exit       - Exit program\n\n";
        }
        else if (cmd == "exit") {
            break;
        }
        else {
            cout << "Command not found\n";
        }

        cout << "\nRun another command? (y/n): ";
        char c;
        cin >> c;

        if (c == 'n' || c == 'N')
            break;
    }

    cout << "\nExiting Mini Linux OS...\n";
    return 0;
}
